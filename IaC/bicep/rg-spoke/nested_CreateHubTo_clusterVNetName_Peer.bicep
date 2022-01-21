param resourceId_Microsoft_Network_virtualNetworks_variables_clusterVNetName string
param variables_hubNetworkName ? /* TODO: fill in correct type */
param variables_clusterVNetName ? /* TODO: fill in correct type */

resource variables_hubNetworkName_hub_to_variables_clusterVNetName 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2020-05-01' = {
  name: '${variables_hubNetworkName}/hub-to-${variables_clusterVNetName}'
  properties: {
    remoteVirtualNetwork: {
      id: resourceId_Microsoft_Network_virtualNetworks_variables_clusterVNetName
    }
    allowForwardedTraffic: false
    allowGatewayTransit: false
    allowVirtualNetworkAccess: true
    useRemoteGateways: false
  }
}