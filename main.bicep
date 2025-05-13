//// Networking and Security for Contoso's Azure Environment
//// This Bicep template deploys a hub-and-spoke network architecture with Azure Firewall, API Management, and Application Gateway.
@description('App Gateway Public IP')
resource appGatewayNsg 'Microsoft.Network/networkSecurityGroups@2023-02-01' = {
  name: 'AppGatewaySubnet-NSG'
  location: resourceGroup().location
  properties: {
    securityRules: [
      {
        name: 'AllowGatewayManager'
        properties: {
          priority: 100
          direction: 'Inbound'
          access: 'Allow'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRanges: [
            '65200-65535'
          ]
          sourceAddressPrefix: 'GatewayManager'
          destinationAddressPrefix: '*'
        }
      }
      {
        name: 'AllowHttpsFromInternet'
        properties: {
          priority: 110
          direction: 'Inbound'
          access: 'Allow'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '443'
          sourceAddressPrefix: 'Internet'
          destinationAddressPrefix: '*'
        }
      }
      {
        name: 'AllowHttpFromInternet'
        properties: {
          priority: 120
          direction: 'Inbound'
          access: 'Allow'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '80'
          sourceAddressPrefix: 'Internet'
          destinationAddressPrefix: '*'
        }
      }
      {
        name: 'AllowHttpsFromAzureLoadBalancer'
        properties: {
          priority: 130
          direction: 'Inbound'
          access: 'Allow'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '443'
          sourceAddressPrefix: 'AzureLoadBalancer'
          destinationAddressPrefix: '*'
        }
      }
      {
        name: 'DenyAllInbound'
        properties: {
          priority: 4096
          direction: 'Inbound'
          access: 'Deny'
          protocol: '*'
          sourcePortRange: '*'
          destinationPortRange: '*'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
        }
      }
      {
        name: 'AllowToAPIMSubnet'
        properties: {
          priority: 100
          direction: 'Outbound'
          access: 'Allow'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '443'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '10.1.1.0/24'
        }
      }
      {
        name: 'AllowToInternetForCertValidation'
        properties: {
          priority: 110
          direction: 'Outbound'
          access: 'Allow'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '443'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: 'Internet'
        }
      }
      {
        name: 'AllowAllOutbound'
        properties: {
          priority: 120
          direction: 'Outbound'
          access: 'Allow'
          protocol: '*'
          sourcePortRange: '*'
          destinationPortRange: '*'
          sourceAddressPrefix: '10.1.0.0/24'
          destinationAddressPrefix: '*'
        }
      }
    ]
  }
}

@description('APIMSubnet NSG')
resource apimNsg 'Microsoft.Network/networkSecurityGroups@2023-02-01' = {
  name: 'APIMSubnet-NSG'
  location: resourceGroup().location
  properties: {
    securityRules: [
      {
        name: 'AllowApiManagement'
        properties: {
          priority: 100
          direction: 'Inbound'
          access: 'Allow'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '3443'
          sourceAddressPrefix: 'ApiManagement'
          destinationAddressPrefix: '*'
        }
      }
      {
        name: 'AllowHttpsFromAppGatewaySubnet'
        properties: {
          priority: 110
          direction: 'Inbound'
          access: 'Allow'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '443'
          sourceAddressPrefix: '10.1.0.0/24'
          destinationAddressPrefix: '*'
        }
      }
      {
        name: 'AllowHttpsFromAzureLoadBalancer'
        properties: {
          priority: 120
          direction: 'Inbound'
          access: 'Allow'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '443'
          sourceAddressPrefix: 'AzureLoadBalancer'
          destinationAddressPrefix: '*'
        }
      }
      {
        name: 'DenyAllInbound'
        properties: {
          priority: 4096
          direction: 'Inbound'
          access: 'Deny'
          protocol: '*'
          sourcePortRange: '*'
          destinationPortRange: '*'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
        }
      }
      {
        name: 'AllowToAppSubnet'
        properties: {
          priority: 100
          direction: 'Outbound'
          access: 'Allow'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRanges: [
            '80'
            '443'
          ]
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '10.1.2.0/24'
        }
      }
      {
        name: 'DenyAllOutbound'
        properties: {
          priority: 4096
          direction: 'Outbound'
          access: 'Deny'
          protocol: '*'
          sourcePortRange: '*'
          destinationPortRange: '*'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
        }
      }
    ]
  }
}

@description('AppSubnet NSG')
resource appNsg 'Microsoft.Network/networkSecurityGroups@2023-02-01' = {
  name: 'AppSubnet-NSG'
  location: resourceGroup().location
  properties: {
    securityRules: [
      {
        name: 'AllowHttpsFromAPIMSubnet'
        properties: {
          priority: 100
          direction: 'Inbound'
          access: 'Allow'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '443'
          sourceAddressPrefix: '10.1.1.0/24'
          destinationAddressPrefix: '*'
        }
      }
      {
        name: 'DenyAllInbound'
        properties: {
          priority: 4096
          direction: 'Inbound'
          access: 'Deny'
          protocol: '*'
          sourcePortRange: '*'
          destinationPortRange: '*'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
        }
      }
      {
        name: 'AllowToDatabaseSubnet'
        properties: {
          priority: 100
          direction: 'Outbound'
          access: 'Allow'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '1433'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '10.1.3.0/24'
        }
      }
      {
        name: 'DenyAllOutbound'
        properties: {
          priority: 4096
          direction: 'Outbound'
          access: 'Deny'
          protocol: '*'
          sourcePortRange: '*'
          destinationPortRange: '*'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
        }
      }
    ]
  }
}

@description('DatabaseSubnet NSG')
resource databaseNsg 'Microsoft.Network/networkSecurityGroups@2023-02-01' = {
  name: 'DatabaseSubnet-NSG'
  location: resourceGroup().location
  properties: {
    securityRules: [
      {
        name: 'AllowFromAppSubnet'
        properties: {
          priority: 100
          direction: 'Inbound'
          access: 'Allow'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '1443'
          sourceAddressPrefix: '10.1.2.0/24'
          destinationAddressPrefix: '*'
        }
      }
      {
        name: 'DenyAllInbound'
        properties: {
          priority: 4096
          direction: 'Inbound'
          access: 'Deny'
          protocol: '*'
          sourcePortRange: '*'
          destinationPortRange: '*'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
        }
      }
      {
        name: 'DenyAllOutbound'
        properties: {
          priority: 4096
          direction: 'Outbound'
          access: 'Deny'
          protocol: '*'
          sourcePortRange: '*'
          destinationPortRange: '*'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
        }
      }
    ]
  }
}

@description('DatabaseSubnet NSG')
resource managementNsg 'Microsoft.Network/networkSecurityGroups@2023-02-01' = {
  name: 'ManagementSubnet-NSG'
  location: resourceGroup().location
  properties: {
    securityRules: [
      {
        name: 'AllowFromSpokeVnet'
        properties: {
          priority: 100
          direction: 'Inbound'
          access: 'Allow'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '443'
          sourceAddressPrefix: '10.1.0.0/16'
          destinationAddressPrefix: '*'
        }
      }
      {
        name: 'DenyAllInbound'
        properties: {
          priority: 4096
          direction: 'Inbound'
          access: 'Deny'
          protocol: '*'
          sourcePortRange: '*'
          destinationPortRange: '*'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
        }
      }
      {
        name: 'DenyAllOutbound'
        properties: {
          priority: 4096
          direction: 'Outbound'
          access: 'Deny'
          protocol: '*'
          sourcePortRange: '*'
          destinationPortRange: '*'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
        }
      }
    ]
  }
}

@description('Hub VNET')
resource hubVnet 'Microsoft.Network/virtualNetworks@2023-02-01' = {
  name: 'HubVnet'
  location: resourceGroup().location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.0.0.0/16'
      ]
    }
    subnets: [
      {
        name: 'GatewaySubnet'
        properties: {
          addressPrefix: '10.0.0.0/26'
        }
      }
      {
        name: 'AzureFirewallSubnet'
        properties: {
          addressPrefix: '10.0.1.0/26'
        }
      }
      {
        name: 'AzureBastionSubnet'
        properties: {
          addressPrefix: '10.0.2.0/26'
        }
      }
      {
        name: 'ManagementSubnet'
        properties: {
          addressPrefix: '10.0.3.0/24'
        }
      }
    ]
  }
}

@description('Spoke VNET')
resource spokeVnet 'Microsoft.Network/virtualNetworks@2023-02-01' = {
  name: 'SpokeVnet'
  location: resourceGroup().location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.1.0.0/16'
      ]
    }
    subnets: [
      {
        name: 'AppGatewaySubnet'
        properties: {
          addressPrefix: '10.1.0.0/24'
          networkSecurityGroup: {
            id: appGatewayNsg.id
          }
        }
      }
      {
        name: 'APIMSubnet'
        properties: {
          addressPrefix: '10.1.1.0/24'
          networkSecurityGroup: {
            id: apimNsg.id
          }
        }
      }
      {
        name: 'AppSubnet'
        properties: {
          addressPrefix: '10.1.2.0/24'
          networkSecurityGroup: {
            id: appNsg.id
          }
        }
      }
      {
        name: 'DatabaseSubnet'
        properties: {
          addressPrefix: '10.1.3.0/24'
          networkSecurityGroup: {
            id: databaseNsg.id
          }
        }
      }
      {
      name: 'ManagementSubnet'
      properties: {
          addressPrefix: '10.1.4.0/24'
          networkSecurityGroup: {
          id: managementNsg.id
          }
        }
      }
    ]
  }
}

@description('Hub-Spoke VNET Peering')
resource hubToSpokePeering 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2023-02-01' = {
  name: '${hubVnet.name}-to-${spokeVnet.name}'
  parent: hubVnet
  properties: {
    remoteVirtualNetwork: {
      id: spokeVnet.id
    }
    allowVirtualNetworkAccess: true
    allowForwardedTraffic: true
    allowGatewayTransit: false
  }
}

resource spokeToHubPeering 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2023-02-01' = {
  name: '${spokeVnet.name}-to-${hubVnet.name}'
  parent: spokeVnet
  properties: {
    remoteVirtualNetwork: {
      id: hubVnet.id
    }
    allowVirtualNetworkAccess: true
    allowForwardedTraffic: true
    useRemoteGateways: false
  }
}

//// Key Vault for Secrets & Certificates
@description('Key Vault for Secrets')
var vaultname = 'contosokv${uniqueString(resourceGroup().id)}'
resource keyVault 'Microsoft.KeyVault/vaults@2024-11-01' = {
  name: vaultname
  location: resourceGroup().location
  properties: {
    sku: {
      family: 'A'
      name: 'standard'
    }
    tenantId: subscription().tenantId
    accessPolicies: []
    enableSoftDelete: true
    softDeleteRetentionInDays: 30
    enablePurgeProtection: true
    enableRbacAuthorization: true
    publicNetworkAccess: 'Enabled'
    networkAcls: {
      bypass: 'AzureServices'
      defaultAction: 'Allow'
    }
  }
}

// Private Endpoint for Key Vault in AppSubnet
resource keyVaultPrivateEndpoint 'Microsoft.Network/privateEndpoints@2023-05-01' = {
  name: 'kv-pe'
  location: resourceGroup().location
  properties: {
    subnet: {
      id: spokeVnet.properties.subnets[4].id // ManagementSubnet
    }
    privateLinkServiceConnections: [
      {
        name: 'kv-privatelink'
        properties: {
          privateLinkServiceId: keyVault.id
          groupIds: [
            'vault'
          ]
        }
      }
    ]
  }
}

// Private DNS Zone for Key Vault
resource kvPrivateDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: 'privatelink.vaultcore.azure.net'
  location: 'global'
}

// Virtual Network Link to Spoke VNET
resource kvDnsZoneVnetLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  name: 'spokeVnet-link'
  parent: kvPrivateDnsZone
  location: 'global'
  properties: {
    virtualNetwork: {
      id: spokeVnet.id
    }
    registrationEnabled: false
  }
}

// DNS A record for Key Vault private endpoint
resource kvDnsARecord 'Microsoft.Network/privateDnsZones/A@2020-06-01' = {
  name: keyVault.name
  parent: kvPrivateDnsZone
  properties: {
    aRecords: [
      {
        ipv4Address: keyVaultPrivateEndpoint.properties.customDnsConfigs[0].ipAddresses[0]
      }
    ]
    ttl: 3600
  }
}

// Private DNS Zone Group for Private Endpoint
resource kvPrivateDnsZoneGroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2023-05-01' = {
  name: 'default'
  parent: keyVaultPrivateEndpoint
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'kvDnsZoneConfig'
        properties: {
          privateDnsZoneId: kvPrivateDnsZone.id
        }
      }
    ]
  }
}

// resource keyVaultAccessPolicy 'Microsoft.KeyVault/vaults/accessPolicies@2024-11-01' = {
//   name: 'add'
//   parent: keyVault
//   properties: {
//     accessPolicies: [
//       {
//         tenantId: subscription().tenantId
//         objectId: apiManagement.identity.principalId
//         permissions: {
//           keys: [
//             'get'
//             'list'
//           ]
//           secrets: [
//             'get'
//             'list'
//           ]
//           certificates: [
//             'get'
//             'list'
//           ]
//         }
//       }
//     ]
//   }
// }

//// Azure Firewall settings
// @description('Public IP for Azure Firewall')
// resource azfwPublicIp 'Microsoft.Network/publicIPAddresses@2024-05-01' = {
//   name: 'AzureFirewallPublicIP'
//   location: resourceGroup().location
//   sku: {
//     name: 'Standard'
//     tier: 'Regional'
//   }
//   properties: {
//     publicIPAllocationMethod: 'Static'
//   }
// }

// @description('Azure Firewall Policy')
// resource firewallPolicy 'Microsoft.Network/firewallPolicies@2024-05-01' = {
//   name: 'AzureFirewallPolicy'
//   location: resourceGroup().location
//     properties: {
//       sku: {
//         tier: 'Standard'
//       }
//     }
// }
  
// @description('Azure Firewall')
// resource azureFirewall 'Microsoft.Network/azureFirewalls@2024-05-01' = {
//   name: 'AzureFirewall'
//   location: resourceGroup().location
//   properties: {
//     sku: {
//       name: 'AZFW_VNet'
//       tier: 'Standard'
//     }
//     ipConfigurations: [
//       {
//         name: 'AzureFirewallIpConfig'
//         properties: {
//           subnet: {
//             id: hubVnet.properties.subnets[1].id // AzureFirewallSubnet
//           }
//           publicIPAddress: {
//             id: azfwPublicIp.id
//           }
//         }
//       }
//     ]
//     firewallPolicy: {
//       id: firewallPolicy.id
//     }
//   }
// }

// @description('Azure Firewall Rule Collection Group')
// resource firewallRuleCollectionGroup 'Microsoft.Network/firewallPolicies/ruleCollectionGroups@2024-05-01' = {
//   name: 'DefaultRuleCollectionGroup'
//   parent: firewallPolicy
//   properties: {
//     priority: 100
//     ruleCollections: [
//       {
//         name: 'Allow-OnPrem-To-Azure'
//         priority: 100
//         ruleCollectionType: 'FirewallPolicyFilterRuleCollection'
//         action: {
//           type: 'Allow'
//         }
//         rules: [
//           {
//             name: 'Allow-OnPrem-To-AppGateway'
//             ruleType: 'NetworkRule'
//             sourceAddresses: [
//               '172.16.0.0/16'
//             ]
//             destinationAddresses: [
//               '10.1.0.0/24'
//             ]
//             destinationPorts: [
//               '443'
//             ]
//             ipProtocols: [
//               'TCP'
//             ]
//           }
//         ]
//       }
//       {
//         name: 'Allow-Azure-To-OnPrem'
//         priority: 110
//         ruleCollectionType: 'FirewallPolicyFilterRuleCollection'
//         action: {
//           type: 'Allow'
//         }
//         rules: [
//           {
//             name: 'Allow-APIM-To-OnPrem-Services'
//             ruleType: 'NetworkRule'
//             sourceAddresses: [
//               '10.1.1.0/24'
//             ]
//             destinationAddresses: [
//               '172.16.1.0/24'
//             ]
//             destinationPorts: [
//               '443'
//             ]
//             ipProtocols: [
//               'TCP'
//             ]
//           }
//         ]
//       }
//       // {
//       //   name: 'Allow-FrontDoor-Origins'
//       //   priority: 120
//       //   ruleCollectionType: 'FirewallPolicyFilterRuleCollection'
//       //   action: {
//       //     type: 'Allow'
//       //   }
//       //   rules: [
//       //     {
//       //       name: 'Allow-FrontDoor-Backends'
//       //       ruleType: 'ApplicationRule'
//       //       sourceAddresses: [
//       //         '*'
//       //       ]
//       //       targetFqdns: [
//       //         '*.contoso.com'
//       //         'api.contoso.com'
//       //       ]
//       //       protocols: [
//       //         {
//       //           protocolType: 'Https'
//       //           port: 443
//       //         }
//       //       ]
//       //     }
//       //   ]
//       // }
//       // {
//       //   name: 'Allow-Azure-Services'
//       //   priority: 130
//       //   ruleCollectionType: 'FirewallPolicyFilterRuleCollection'
//       //   action: {
//       //     type: 'Allow'
//       //   }
//       //   rules: [
//       //     {
//       //       name: 'Allow-KeyVault'
//       //       ruleType: 'ApplicationRule'
//       //       sourceAddresses: [
//       //         '10.1.0.0/24'
//       //         '10.1.1.0/24'
//       //         '10.1.2.0/24'
//       //       ]
//       //       targetFqdns: [
//       //         'https://${vaultname}.vault.azure.net/'
//       //       ]
//       //       protocols: [
//       //         {
//       //           protocolType: 'Https'
//       //           port: 443
//       //         }
//       //       ]
//       //     }
//       //     {
//       //       name: 'Allow-AzureMonitor'
//       //       ruleType: 'ApplicationRule'
//       //       sourceAddresses: [
//       //         '*'
//       //       ]
//       //       targetFqdns: [
//       //         '*.monitor.azure.com'
//       //         '*.ods.opinsights.azure.com'
//       //         '*.oms.opinsights.azure.com'
//       //       ]
//       //       protocols: [
//       //         {
//       //           protocolType: 'Https'
//       //           port: 443
//       //         }
//       //       ]
//       //     }
//       //   ]
//       // }
//     ]
//   }
// }

// @description('User Defined Route to Azure Firewall')
// resource firewallUdr 'Microsoft.Network/routeTables@2023-02-01' = {
//   name: 'Firewall-UDR'
//   location: resourceGroup().location
//   properties: {
//     routes: [
//       {
//         name: 'To-ANYTHING-Via-Firewall'
//         properties: {
//           addressPrefix: '0.0.0.0/0'
//           nextHopType: 'VirtualAppliance'
//           nextHopIpAddress: azureFirewall.properties.ipConfigurations[0].properties.privateIPAddress
//         }
//       }
//     ]
//   }
// }

// resource apimSubnetUdrAssoc 'Microsoft.Network/virtualNetworks/subnets@2023-02-01' = {
//   parent: spokeVnet
//   name: 'APIMSubnet'
//   properties: {
//     addressPrefix: '10.1.1.0/24'
//     routeTable: {
//       id: firewallUdr.id
//     }
//   }
// }

// resource appSubnetUdrAssoc 'Microsoft.Network/virtualNetworks/subnets@2023-02-01' = {
//   parent: spokeVnet
//   name: 'AppSubnet'
//   properties: {
//     addressPrefix: '10.1.2.0/24'
//     routeTable: {
//       id: firewallUdr.id
//     }
//   }
// }

// resource databaseSubnetUdrAssoc 'Microsoft.Network/virtualNetworks/subnets@2023-02-01' = {
//   parent: spokeVnet
//   name: 'DatabaseSubnet'
//   properties: {
//     addressPrefix: '10.1.3.0/24'
//     routeTable: {
//       id: firewallUdr.id
//     }
//   }
// }

// resource managementSubnetUdrAssoc 'Microsoft.Network/virtualNetworks/subnets@2023-02-01' = {
//   parent: hubVnet
//   name: 'ManagementSubnet'
//   properties: {
//     addressPrefix: '10.0.3.0/24'
//     routeTable: {
//       id: firewallUdr.id
//     }
//   }
// }

//// APIM settings
// @description('APIM Public IP')
// resource apimPublicIp 'Microsoft.Network/publicIPAddresses@2024-05-01' = {
//   name: 'apimPublicIp'
//   location: resourceGroup().location
//   sku: {
//     name: 'Standard'
//     tier: 'Regional'
//   }
//   properties: {
//     publicIPAllocationMethod: 'Static'
//   }
// }

// @description('API Management Service')
// resource apiManagement 'Microsoft.ApiManagement/service@2022-09-01-preview' = {
//   name: 'ContosoAPIM-NT'
//   location: resourceGroup().location
//   sku: {
//     name: 'Premium'
//     capacity: 2
//   }
//   zones: [
//     '1'
//     '2'
//     '3'
//   ]
//   identity: {
//     type: 'SystemAssigned'
//   }
//   properties: {
//     publisherEmail: 'admin@contoso.com'
//     publisherName: 'Contoso'
//     customProperties: {
//       'Microsoft.WindowsAzure.ApiManagement.Gateway.Security.Ciphers.TripleDes168': 'false'
//       'Microsoft.WindowsAzure.ApiManagement.Gateway.Security.Protocols.Tls11': 'false'
//       'Microsoft.WindowsAzure.ApiManagement.Gateway.Security.Protocols.Tls10': 'false'
//     }
//     virtualNetworkType: 'External'
//     virtualNetworkConfiguration: {
//       subnetResourceId: spokeVnet.properties.subnets[1].id // APIMSubnet
//     }
//     publicIpAddressId: apimPublicIp.id
//   }
// }

//// Application Gateway settings
// @description('AppGateway Public IP')
// resource appGatewayPublicIp 'Microsoft.Network/publicIPAddresses@2024-05-01' = {
//   name: 'AppGatewayPublicIP'
//   location: resourceGroup().location
//   sku: {
//     name: 'Standard'
//     tier: 'Regional'
//   }
//   properties: {
//     publicIPAllocationMethod: 'Static'
//   }
// }
//


//// Azure Front Door settings
// @description('Azure Front Door Profile')
// resource frontDoorProfile 'Microsoft.Cdn/profiles@2025-04-15' = {
//   name: 'ContosoFrontDoorProfile'
//   location: 'global'
//   sku: {
//     name: 'Premium_AzureFrontDoor'
//   }
//   // properties: {
//   //   enabledState: 'Enabled'
//   // }
// }
//
// @description('Azure Front Door WAF Policy')
// resource frontDoorWafPolicy 'Microsoft.Network/FrontDoorWebApplicationFirewallPolicies@2024-02-01' = {
//   name: 'ContosoWAFPolicy'
//   location: 'global'
//   properties: {
//     customRules: {
//       rules: [
//         { 
//           name: 'GeoFiltering'
//           priority: 1
//           ruleType: 'MatchRule'
//           matchConditions: [
//             {
//               matchVariable: 'RemoteAddr'
//               operator: 'GeoMatch'
//               matchValue: [
//                 'US'
//                 'CA'
//               ]
//             }
//           ]
//           action: 'Block'
//       }
//       {
//         name: 'RateLimiting'
//         priority: 2
//         ruleType: 'RateLimitRule'
//         rateLimitThreshold: 1000
//         rateLimitDurationInMinutes: 1
//         matchConditions: [
//           {
//             matchVariable: 'RemoteAddr'
//             operator: 'IPMatch'
//             matchValue: [ // known Akamai IP ranges
//               '23.235.32.0/20'
//               '43.249.72.0/22'
//               '63.245.64.0/18'
//               '72.247.0.0/16'
//               '96.17.8.0/21'
//               '96.17.16.0/20'
//               '96.6.0.0/17'
//               '104.64.0.0/15'
//               '184.24.0.0/13'
//               '184.50.0.0/16'
//               '184.84.0.0/14'
//               '184.94.0.0/15'
//               '184.106.0.0/16'
//               '198.18.0.0/15'
//               '198.41.128.0/17'
//             ]
//           }
//         ]
//         action: 'Block'
//       }
//       ]
//     }
//     managedRules: {
//       managedRuleSets: [
//         {
//           ruleSetType: 'Microsoft_BotManagerRuleSet'
//           ruleSetVersion: '1.0'
//         }
//       ]
//     }
//     policySettings: {
//       mode: 'Prevention'
//     }
//   }
// }


//// Diagnostic settings for resources above
@description('Log Analytics Workspace')
resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2025-02-01' = {
  name: 'ContosoLogAnalytics'
  location: resourceGroup().location
  properties: {
    sku: {
      name: 'PerGB2018'
    }
    retentionInDays: 30
  }
}

// // Private Endpoint for Log Analytics Workspace
// resource logAnalyticsPrivateEndpoint 'Microsoft.Network/privateEndpoints@2023-05-01' = {
//   name: 'loganalytics-pe'
//   location: resourceGroup().location
//   properties: {
//     subnet: {
//       id: spokeVnet.properties.subnets[4].id // ManagementSubnet
//     }
//     privateLinkServiceConnections: [
//       {
//         name: 'loganalytics-privatelink'
//         properties: {
//           privateLinkServiceId: logAnalyticsWorkspace.id
//           groupIds: [
//             'workspaces'
//           ]
//         }
//       }
//     ]
//   }
// }

// // Private DNS Zone for Log Analytics
// resource logAnalyticsPrivateDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' = {
//   name: 'privatelink.oms.opinsights.azure.com'
//   location: 'global'
// }

// // VNET Link for Log Analytics DNS Zone
// resource logAnalyticsDnsZoneVnetLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
//   name: 'spokeVnet-link-loganalytics'
//   parent: logAnalyticsPrivateDnsZone
//   location: 'global'
//   properties: {
//     virtualNetwork: {
//       id: spokeVnet.id
//     }
//     registrationEnabled: false
//   }
// }

// // Private DNS Zone Group for Log Analytics Private Endpoint
// resource logAnalyticsPrivateDnsZoneGroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2023-05-01' = {
//   name: 'default'
//   parent: logAnalyticsPrivateEndpoint
//   properties: {
//     privateDnsZoneConfigs: [
//       {
//         name: 'logAnalyticsDnsZoneConfig'
//         properties: {
//           privateDnsZoneId: logAnalyticsPrivateDnsZone.id
//         }
//       }
//     ]
//   }
// }

@description('Storage Account for Diagnostics')
resource diagnosticsStorageAccount 'Microsoft.Storage/storageAccounts@2024-01-01' = {
  name: 'contoso${uniqueString(resourceGroup().id)}'
  location: resourceGroup().location
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
  properties: {
    accessTier: 'Hot'
  }
}

// Private Endpoint for Storage Account
resource storagePrivateEndpoint 'Microsoft.Network/privateEndpoints@2023-05-01' = {
  name: 'storage-pe'
  location: resourceGroup().location
  properties: {
    subnet: {
      id: spokeVnet.properties.subnets[4].id // ManagementSubnet
    }
    privateLinkServiceConnections: [
      {
        name: 'storage-privatelink'
        properties: {
          privateLinkServiceId: diagnosticsStorageAccount.id
          groupIds: [
            'blob'
          ]
        }
      }
    ]
  }
}

// Private DNS Zone for Storage Account (blob)
resource storageBlobPrivateDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: 'privatelink.blob.core.windows.net'
  location: 'global'
}

// VNET Link for Storage Blob DNS Zone
resource storageBlobDnsZoneVnetLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  name: 'spokeVnet-link-storageblob'
  parent: storageBlobPrivateDnsZone
  location: 'global'
  properties: {
    virtualNetwork: {
      id: spokeVnet.id
    }
    registrationEnabled: false
  }
}

// Private DNS Zone Group for Storage Private Endpoint
resource storagePrivateDnsZoneGroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2023-05-01' = {
  name: 'default'
  parent: storagePrivateEndpoint
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'storageBlobDnsZoneConfig'
        properties: {
          privateDnsZoneId: storageBlobPrivateDnsZone.id
        }
      }
    ]
  }
}

// @description('Diagnostic Settings for Front Door')
// resource frontDoorDiagnostics 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
//   name: 'FrontDoorDiagnostics'
//   scope: frontDoorProfile
//   properties: {
//     logs: [
//       {
//         category: 'FrontdoorAccessLog'
//         enabled: true
//       }
//       {
//         category: 'FrontdoorWebApplicationFirewallLog'
//         enabled: true
//       }
//     ]
//     metrics: []
//     workspaceId: logAnalyticsWorkspace.id
//     storageAccountId: diagnosticsStorageAccount.id
//   }
// }

// @description('Diagnostic Settings for APIM')
// resource apimDiagnostics 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
//   name: 'APIMDiagnostics'
//   scope: apiManagement
//   properties: {
//     logs: [
//       {
//         category: 'GatewayLogs'
//         enabled: true
//       }
//       {
//         category: 'WebSocketConnectionLogs'
//         enabled: true
//       }
//       {
//         category: 'DeveloperPortalAuditLogs'
//         enabled: true
//       }
//       {
//         category: 'GatewayLlmLogs'
//         enabled: true
//       }
//     ]
//     metrics: []
//     workspaceId: logAnalyticsWorkspace.id
//   }
// }

// @description('Diagnostic Settings for Azure Firewall')
// resource azureFirewallDiagnostics 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
//   name: 'AzureFirewallDiagnostics'
//   scope: azureFirewall
//   properties: {
//     logs: [
//       {
//         category: 'AZFWNetworkRule'
//         enabled: true
//       }
//       {
//         category: 'AZFWApplicationRule'
//         enabled: true
//       }
//       {
//         category: 'AZFWThreatIntel'
//         enabled: true
//       }
//     ]
//     metrics: []
//     workspaceId: logAnalyticsWorkspace.id
//   }
// }
