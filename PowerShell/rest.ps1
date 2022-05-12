$subscriptionId = "0b9c4dfd-d9ca-477a-b279-897de40f2d08"  # $token = az account get-access-token --query accessToken --output tsv 
$token = (Get-AzAccessToken).Token
$authheaders = @{
    authorization = "Bearer $token"
}

$ContentType = "application/json"
$prefix = "alex-api"

# to get list of virtual machines in subscription

# $restUri = "https://management.azure.com/subscriptions/0b9c4dfd-d9ca-477a-b279-897de40f2d08/providers/Microsoft.Compute/virtualMachines?api-version=2021-03-01"
# $response = Invoke-RestMethod -Uri $restUri -Method Get -Headers $authHeaders -ContentType $ContentType
# $response.value | Select-Object Name, location

# to create a resource group
$rsgName = "$prefix-rsg"
$rsgParams = @{
    Uri = "https://management.azure.com/subscriptions/$subscriptionId/resourcegroups/${rsgName}?api-version=2021-04-01"
    body = '{
        "location" : "westus"
    }'

}

Invoke-RestMethod -Headers $authheaders -Method Put -ContentType $ContentType @rsgParams 

# to create an app service plan

# $appservicePlan = "$prefix-appPlan"
# $appplanParams = @{
#     Uri = "https://management.azure.com/subscriptions/$subscriptionId/resourceGroups/$rsgName/providers/Microsoft.Web/serverfarms/${appservicePlan}?api-version=2021-02-01"
#     body = '{
#         "kind": "app",
#         "location": "West US",
#         "properties": {},
#         "sku": {
#           "name": "P1",
#           "tier": "Premium",
#           "size": "P1",
#           "family": "P",
#           "capacity": 1
#         }
#     }'
# }

# $appPlanResponse = Invoke-RestMethod -Headers $authheaders -Method Put -ContentType $ContentType @appplanParams
# $appPlanResponse.id

#to create a virtual network
$vnetName = "$prefix-vnet"
$vnetParams = @{
    Uri = "https://management.azure.com/subscriptions/$subscriptionId/resourceGroups/$rsgName/providers/Microsoft.Network/virtualNetworks/${vnetName}?api-version=2021-08-01"
    body = '{
        "location" : "westus",
        "properties":{
            "addressSpace": {
                "addressPrefixes": [
                  "10.0.0.0/16"
                ]
              }
        }
    }'
}

Invoke-RestMethod  -Method Put -Headers $authheaders -ContentType $ContentType @vnetParams

#to create a subnet

$subnetName = "$vnetName-subnet1"
$subnetParams = @{
    Uri = "https://management.azure.com/subscriptions/$subscriptionId/resourceGroups/$rsgName/providers/Microsoft.Network/virtualNetworks/$vnetName/subnets/${subnetName}?api-version=2021-08-01"
    body = '{
        "properties": {
            "addressPrefix": "10.0.1.0/24"
          }
    }'
}
$subnetResponse = Invoke-RestMethod  -Method Put -Headers $authheaders -ContentType $ContentType @subnetParams

#to create a public Ip Address
$vmName = "$prefix-vm"
$nicName = "$vmName-nic"
$pipName = "$nicName-pip"
$pipParams = @{
    Uri = "https://management.azure.com/subscriptions/$subscriptionId/resourceGroups/$rsgName/providers/Microsoft.Network/publicIPAddresses/${pipName}?api-version=2021-08-01"
    body = '{
        "location": "westus",
        "properties": {
            "publicIPAllocationMethod": "Static",
            "publicIPAddressVersion": "IPv4"
          }
    }'
}
$pipResponse = Invoke-RestMethod  -Method Put -Headers $authheaders -ContentType $ContentType @pipParams

# $subnetResponse.id
# $pipResponse.id

#to create network interface

$nicParams = @{
    Uri = "https://management.azure.com/subscriptions/$subscriptionId/resourceGroups/$rsgName/providers/Microsoft.Network/networkInterfaces/${nicName}?api-version=2021-08-01"
    body = '{
        "location": "westus",
        "properties": {
            "ipConfigurations": [
              {
                "name": "ipconfig1",
                "properties": {
                  "publicIPAddress": {
                    "id": "/subscriptions/0b9c4dfd-d9ca-477a-b279-897de40f2d08/resourceGroups/alex-api-rsg/providers/Microsoft.Network/publicIPAddresses/alex-api-vm-nic-pip"
                  },
                  "subnet": {
                    "id": "/subscriptions/0b9c4dfd-d9ca-477a-b279-897de40f2d08/resourceGroups/alex-api-rsg/providers/Microsoft.Network/virtualNetworks/alex-api-vnet/subnets/alex-api-vnet-subnet1"
                  }
                }
              }
            ]
          }
          
    }'
}

$nicResponse = Invoke-RestMethod  -Method Put -Headers $authheaders -ContentType $ContentType @nicParams
# $nicResponse.id

$vmParams = @{
    Uri = "https://management.azure.com/subscriptions/$subscriptionId/resourceGroups/$rsgName/providers/Microsoft.Compute/virtualMachines/${vmName}?api-version=2021-11-01"
    body = '{
        "location": "westus",
        "properties": {
          "hardwareProfile": {
            "vmSize": "Standard_D1_v2"
          },
          "storageProfile": {
            "imageReference": {
              "sku": "2019-Datacenter",
              "publisher": "MicrosoftWindowsServer",
              "version": "latest",
              "offer": "WindowsServer"
            },
            "osDisk": {
              "caching": "ReadWrite",
              "managedDisk": {
                "storageAccountType": "Standard_LRS"
              },
              "name": "vmOsdisk",
              "createOption": "FromImage"
            }
          },
          "networkProfile": {
            "networkInterfaces": [
              {
                "id": "/subscriptions/0b9c4dfd-d9ca-477a-b279-897de40f2d08/resourceGroups/alex-api-rsg/providers/Microsoft.Network/networkInterfaces/alex-api-vm-nic",
                "properties": {
                  "primary": true
                }
              }
            ]
          },
          "osProfile": {
            "adminUsername": "alekhya",
            "computerName": "windowsVM",
            "adminPassword": "AArunkumar@2066"
          },
        }
      }'
}

Invoke-RestMethod  -Headers $authheaders -Method Put -ContentType $ContentType @vmParams