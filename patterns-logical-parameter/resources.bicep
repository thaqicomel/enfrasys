param location string = resourceGroup().location

param sqlServerName string = 'myapp${uniqueString(resourceGroup().id)}'

param frontDoorEndpointName string = 'myapp-${uniqueString(resourceGroup().id)}'

param applicationHostName string = 'jodownsll.azurewebsites.net' // TODO

@allowed([
  'Standard_AzureFrontDoor'
  'Premium_AzureFrontDoor'
])
param frontDoorSkuName string = 'Standard_AzureFrontDoor'

param tenants array = [
  {
    id: 'fabrikam'
    domainName: 'fabrikam.com'
  }
  {
    id: 'contoso'
    domainName: 'contoso.com'
  }
]

var frontDoorProfileName = 'MyFrontDoor'
var frontDoorOriginGroupName = 'MyOriginGroup'
var frontDoorOriginName = 'MyAppServiceOrigin'
var frontDoorRouteName = 'MyRoute'

// All tenant-specific resources are created within this module.
module allTenantResources 'all-tenant-resources.bicep' = {
  name: 'all-tenants'
  params: {
    location: location
    tenants: tenants
    sqlServerName: sqlServer.name
    frontDoorProfileName: frontDoorProfile.name
  }
}

// Shared Azure SQL logical server.
resource sqlServer 'Microsoft.Sql/servers@2022-11-01-preview' = {
  name: sqlServerName
  location: location
}

// Shared Front Door resources
resource frontDoorProfile 'Microsoft.Cdn/profiles@2023-05-01' = {
  name: frontDoorProfileName
  location: 'global'
  sku: {
    name: frontDoorSkuName
  }
}

resource frontDoorEndpoint 'Microsoft.Cdn/profiles/afdEndpoints@2023-05-01' = {
  name: frontDoorEndpointName
  parent: frontDoorProfile
  location: 'global'
  properties: {
    enabledState: 'Enabled'
  }
}

resource frontDoorOriginGroup 'Microsoft.Cdn/profiles/originGroups@2023-05-01' = {
  name: frontDoorOriginGroupName
  parent: frontDoorProfile
  properties: {
    loadBalancingSettings: {
      sampleSize: 4
      successfulSamplesRequired: 3
    }
    healthProbeSettings: {
      probePath: '/'
      probeRequestType: 'HEAD'
      probeProtocol: 'Http'
      probeIntervalInSeconds: 100
    }
  }
}

resource frontDoorOrigin 'Microsoft.Cdn/profiles/originGroups/origins@2023-05-01' = {
  name: frontDoorOriginName
  parent: frontDoorOriginGroup
  properties: {
    hostName: applicationHostName
    httpPort: 80
    httpsPort: 443
    priority: 1
    weight: 1000
  }
}

resource frontDoorRoute 'Microsoft.Cdn/profiles/afdEndpoints/routes@2023-05-01' = {
  name: frontDoorRouteName
  parent: frontDoorEndpoint
  dependsOn: [
    allTenantResources
  ]
  properties: {
    originGroup: {
      id: frontDoorOriginGroup.id
    }
    customDomains: allTenantResources.outputs.tenantFrontDoorCustomDomainIds
    supportedProtocols: [
      'Http'
      'Https'
    ]
    patternsToMatch: [
      '/*'
    ]
    
    forwardingProtocol: 'HttpsOnly'
    linkToDefaultDomain: 'Enabled'
    httpsRedirect: 'Enabled'
  }
}
