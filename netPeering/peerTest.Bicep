param location string = resourceGroup().location

resource vnet1 'Microsoft.Network/virtualNetworks@2023-09-01'= {
  name: 'devvnet1.2'
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.10.8.0/21'
      ]
    }
  }
}

resource subnet1 'Microsoft.Network/virtualNetworks/subnets@2023-09-01' = {
  parent: vnet1
  name: 'subnet1.2'
  properties: {
    addressPrefix: '255.255.248.0/21'
    networkSecurityGroup: {
      id: nsg1.id
    }
  }
}

resource vnet2 'Microsoft.Network/virtualNetworks@2023-09-01'= {
  name: 'devvnet2.2'
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.10.8.0/21'
      ]
    }
  }
}

resource subnet2 'Microsoft.Network/virtualNetworks/subnets@2023-09-01' = {
  parent: vnet2
  name: 'subnet2.2'
  dependsOn: [
    //subnet1
  ]
  properties: {
    addressPrefix: '255.255.248.0/21'
    networkSecurityGroup: {
      id: nsg2.id
    }
  }
}

//-----------peer-------
resource hubTovnet1 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2023-09-01' = {
  name: 'devvnethub-To-vnet1.2'
  parent: vnethub
  properties: {
    allowForwardedTraffic: true
    allowGatewayTransit: true
    remoteVirtualNetwork: {
      id: vnet1.id
    }
  }
}

resource vnet1ToHub 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2023-09-01' = {
  name: 'vnet1.2-To-devvnethub'
  parent: vnet1
  properties: {
    allowForwardedTraffic: true
    allowGatewayTransit: true
    remoteVirtualNetwork: {
      id: vnethub.id
    }
  }
}

resource hubTovnet2 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2023-09-01' = {
  name: 'devvnethub-To-vnet2.2'
  parent: vnethub
  properties: {
    allowForwardedTraffic: true
    allowGatewayTransit: true
    remoteVirtualNetwork: {
      id: vnet2.id
    }
  }
}

resource vnet2ToHub 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2023-09-01' = {
  name: 'vnet2.2-To-devvnethub'
  parent: vnet2
  properties: {
    allowForwardedTraffic: true
    allowGatewayTransit: true
    remoteVirtualNetwork: {
      id: vnethub.id
    }
  }
}

//-----------peer-------end

resource vnethub 'Microsoft.Network/virtualNetworks@2023-09-01'= {
  name: 'devvnethub2.0'
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.10.8.0/21'
      ]
    }
  }
}

resource gwsubnet 'Microsoft.Network/virtualNetworks/subnets@2023-09-01' = {
  parent: vnethub
  name: 'GatewaySubnet2.0'
  properties: {
    addressPrefix: '255.255.248.0/21'
  }
}

resource nsg1 'Microsoft.Network/networkSecurityGroups@2023-09-01' = {
  location: location
  name: 'nsg1.2'
  
}

resource nsg2 'Microsoft.Network/networkSecurityGroups@2023-09-01' = {
  location: location
  name: 'nsg2.2'
  
}


