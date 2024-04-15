param resourceGroupName string = 'thaqitry2.0'
param location string = 'eastus'
param adminUsername string = 'yourAdmin' // Define parameter for admin username
param storageAccountName string = 'thaqi${uniqueString(resourceGroup().id)}'


resource storageAccount 'Microsoft.Storage/storageAccounts@2019-06-01' = {
  name: storageAccountName
  location: location
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
}

resource appServicePlan 'Microsoft.Web/serverfarms@2018-02-01' = {
  name: '${resourceGroupName}asp'
  location: location
  sku: {
    name: 'F1'
    tier: 'Free'
  }
}

resource webApp 'Microsoft.Web/sites@2019-08-01' = {
  name: '${resourceGroupName}web'
  location: location
  properties: {
    serverFarmId: appServicePlan.id
  }
}

resource functionApp 'Microsoft.Web/sites@2019-08-01' = {
  name: '${resourceGroupName}func'
  location: location
  properties: {
    serverFarmId: appServicePlan.id
  }
}

resource virtualNetwork 'Microsoft.Network/virtualNetworks@2019-11-01' = {
  name: '${resourceGroupName}vnet'
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.0.0.0/16'
      ]
    }
  }
}

resource subnet 'Microsoft.Network/virtualNetworks/subnets@2019-11-01' = {
  parent: virtualNetwork
  name: 'default'
  properties: {
    addressPrefix: '10.0.0.0/24'
  }
}

resource publicIP 'Microsoft.Network/publicIPAddresses@2019-11-01' = {
  name: '${resourceGroupName}ip2'
  location: location
  properties: {
    publicIPAllocationMethod: 'Dynamic'
  }
}

resource lb 'Microsoft.Network/loadBalancers@2019-11-01' = {
  name: '${resourceGroupName}lb'
  location: location
  properties: {
    frontendIPConfigurations: [
      {
        name: 'LoadBalancerFrontEnd'
        properties: {
          publicIPAddress: {
            id: publicIP.id
          }
        }
      }
    ]
  }
}

resource nic 'Microsoft.Network/networkInterfaces@2019-11-01' = {
  name: '${resourceGroupName}nic'
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: subnet.id
          }
          publicIPAddress: {
            id: publicIP.id
          }
        }
      }
    ]
  }
}

resource vm 'Microsoft.Compute/virtualMachines@2020-06-01' = {
  name: '${resourceGroupName}vm'
  location: location
  properties: {
    hardwareProfile: {
      vmSize: 'Standard_DS1_v2'
    }
    osProfile: {
      computerName: '${resourceGroupName}vm'
      adminUsername: adminUsername
      adminPassword: 'yourPassword'
      linuxConfiguration: {
        disablePasswordAuthentication: false
      }
    }
    storageProfile: {
      osDisk: {
        createOption: 'FromImage'
        managedDisk: {
          storageAccountType: 'Standard_LRS'
        }
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

