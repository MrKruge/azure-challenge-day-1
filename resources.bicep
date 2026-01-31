@description('Location for all resources')
param location string

@description('Admin username for VM')
param adminUsername string

@description('Admin password for VM')
@secure()
param adminPassword string

// ------------------------
// Network Security Group (broken: missing HTTP)
// ------------------------
resource nsg 'Microsoft.Network/networkSecurityGroups@2022-07-01' = {
  name: 'challenge-nsg'
  location: location
  properties: {
    securityRules: [
      {
        name: 'Allow-SSH'
        properties: {
          priority: 1000
          direction: 'Inbound'
          access: 'Allow'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '22'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
        }
      }
      // ❌ No HTTP rule
    ]
  }
}

// ------------------------
// Virtual Network
// ------------------------
resource vnet 'Microsoft.Network/virtualNetworks@2022-07-01' = {
  name: 'challenge-vnet'
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: ['10.0.0.0/16']
    }
    subnets: [
      {
        name: 'web-subnet'
        properties: {
          addressPrefix: '10.0.1.0/24'
          networkSecurityGroup: {
            id: nsg.id
          }
        }
      }
    ]
  }
}

// ------------------------
// Public IP
// ------------------------
resource publicIP 'Microsoft.Network/publicIPAddresses@2022-07-01' = {
  name: 'challenge-public-ip'
  location: location
  properties: {
    publicIPAllocationMethod: 'Dynamic'
  }
}

// ------------------------
// Network Interface
// ------------------------
resource nic 'Microsoft.Network/networkInterfaces@2022-07-01' = {
  name: 'challenge-nic'
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          subnet: {
            id: vnet.properties.subnets[0].id
          }
          publicIPAddress: {
            id: publicIP.id
          }
        }
      }
    ]
  }
}

// ------------------------
// Linux VM
// ------------------------
resource vm 'Microsoft.Compute/virtualMachines@2022-08-01' = {
  name: 'challenge-vm'
  location: location
  properties: {
    hardwareProfile: { vmSize: 'Standard_B1s' }
    osProfile: {
      computerName: 'challengevm'
      adminUsername: adminUsername
      adminPassword: adminPassword
      linuxConfiguration: { disablePasswordAuthentication: false }
    }
    storageProfile: {
      imageReference: {
        publisher: 'Canonical'
        offer: '0001-com-ubuntu-server-jammy'
        sku: '22_04-lts'
        version: 'latest'
      }
      osDisk: { createOption: 'FromImage' }
    }
    networkProfile: { networkInterfaces: [ { id: nic.id } ] }
  }
}

// ------------------------
// Install NGINX via Custom Script Extension
// ------------------------
resource nginx 'Microsoft.Compute/virtualMachines/extensions@2022-08-01' = {
  parent: vm
  name: 'nginx-install'
  location: location
  properties: {
    publisher: 'Microsoft.Azure.Extensions'
    type: 'CustomScript'
    typeHandlerVersion: '2.1'
    settings: {
      commandToExecute: 'sudo apt update && sudo apt install -y nginx && echo "<h1>Cloud Club Azure Challenge</h1>" | sudo tee /var/www/html/index.html'
    }
  }
}

// ------------------------
// Output public IP
// ------------------------
output publicIP string = publicIP.properties.ipAddress
