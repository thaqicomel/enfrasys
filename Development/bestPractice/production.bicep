param location string = 'East US'
param adminUsername string
@secure()
param adminPassword string

module HUB 'hub.bicep' = {
  name: 'all-tenants'
  params: {
    location: location
  }
}

resource vnet 'Microsoft.Network/virtualNetworks@2020-11-01' = HUB.outputs.vnetId

resource publicIP 'Microsoft.Network/publicIPAddresses@2020-11-01' = HUB.outputs.publicIPId

resource nsg 'Microsoft.Network/networkSecurityGroups@2020-11-01' = HUB.outputs.nsgId

resource firewallNSG 'Microsoft.Network/networkSecurityGroups@2020-11-01' = HUB.outputs.firewallNSGId

resource subnet 'Microsoft.Network/virtualNetworks/subnets@2020-11-01' = HUB.outputs.subnetId

module vm1 'vm.bicep' = {
  name: 'vm1'
  params: {
    location: location
    adminUsername: adminUsername
    adminPassword: adminPassword
    subnetId: subnet.id
    publicIPId: publicIP.id
    nsgId: nsg.id
  }
}

module vm2 'vm.bicep' = {
  name: 'vm2'
  params: {
    location: location
    adminUsername: adminUsername
    adminPassword: adminPassword
    subnetId: subnet.id
    publicIPId: publicIP.id
    nsgId: nsg.id
  }
}

// Define additional modules for each VM as needed
