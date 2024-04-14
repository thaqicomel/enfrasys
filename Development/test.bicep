param location string = 'eastus'
param resourceGroupName string = 'myResourceGroup'
param vnetName string = 'myVNet'
param subnetName string = 'mySubnet'
param appName string = 'myApp'
param vmName string = 'myVM'
param nicName string = 'myNIC'

resource vnet 'Microsoft.Network/virtualNetworks@2020-06-01' = {
  name: vnetName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.0.0.0/16'
      ]
    }
    subnets: [
      {
        name: subnetName
        properties: {
          addressPrefix: '10.0.0.0/24'
        }
      }
    ]
  }
}

resource subnet 'Microsoft.Network/virtualNetworks/subnets@2020-06-01' = {
  name: '${vnetName}/${subnetName}'
  parent: vnet
  properties: {
    addressPrefix: '10.0.0.0/24'
  }
}

resource nic 'Microsoft.Network/networkInterfaces@2020-06-01' = {
  name: nicName
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          subnet: {
            id: '${vnet.id}/subnets/${subnetName}'
          }
          privateIPAllocationMethod: 'Dynamic'
        }
      }
    ]
  }
}

resource vm 'Microsoft.Compute/virtualMachines@2020-06-01' = {
  name: vmName
  location: location
  dependsOn: [
    nic
  ]
  properties: {
    hardwareProfile: {
      vmSize: 'Standard_DS1_v2'
    }
    osProfile: {
      computerName: vmName
      adminUsername: 'adminUser'
      adminPassword: 'P@ssw0rd123!'
    }
    storageProfile: {
      imageReference: {
        publisher: 'MicrosoftWindowsServer'
        offer: 'WindowsServer'
        sku: '2019-Datacenter'
        version: 'latest'
      }
      osDisk: {
        createOption: 'FromImage'
        diskSizeGB: 128
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: nic.id
        }
      ]
    }
  }
}

resource firewall 'Microsoft.Network/networkSecurityGroups@2020-06-01' = {
  name: 'myFirewall'
  location: location
  properties: {
    securityRules: [
      {
        name: 'allow-rdp'
        properties: {
          protocol: 'Tcp'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
          destinationPortRange: '3389'
          access: 'Allow'
          direction: 'Inbound'
          priority: 100
        }
      }
    ]
  }
}

resource vpn 'Microsoft.Network/virtualNetworkGateways@2020-06-01' = {
  name: 'myVPNGateway'
  location: location
  properties: {
    vpnType: 'RouteBased'
    sku: {
      name: 'VpnGw1'
      tier: 'VpnGw1'
    }
    ipConfigurations: [
      {
        name: 'myIPConfig'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: '${vnet.id}/subnets/${subnetName}'
          }
        }
      }
    ]
  }
}

resource applicationGateway 'Microsoft.Network/applicationGateways@2020-06-01' = {
  name: 'myAppGateway'
  location: location
  properties: {
    sku: {
      name: 'Standard_Small'
      tier: 'Standard'
    }
    gatewayIPConfigurations: [
      {
        name: 'appGatewayIpConfig'
        properties: {
          subnet: {
            id: '${vnet.id}/subnets/${subnetName}'
          }
        }
      }
    ]
    frontendIPConfigurations: [
      {
        name: 'appGatewayFrontendIP'
        properties: {
          subnet: {
            id: '${vnet.id}/subnets/${subnetName}'
          }
        }
      }
    ]
    frontendPorts: [
      {
        name: 'port_80'
        properties: {
          port: 80
        }
      }
    ]
    backendAddressPools: [
      {
        name: 'appGatewayBackendPool'
        properties: {
          backendAddresses: [
            {
              fqdn: 'mybackend.example.com'
            }
          ]
        }
      }
    ]
    httpListeners: [
      {
        name: 'http_listener'
        properties: {
          frontendIPConfiguration: {
            id: 'appGatewayFrontendIP'
          }
          frontendPort: {
            id: 'port_80'
          }
          protocol: 'Http'
        }
      }
    ]
    requestRoutingRules: [
      {
        name: 'rule1'
        properties: {
          ruleType: 'Basic'
          httpListener: {
            id: 'http_listener'
          }
          backendAddressPool: {
            id: 'appGatewayBackendPool'
          }
          backendHttpSettings: {
            port: 80
            protocol: 'Http'
          }
        }
      }
    ]
  }
}
