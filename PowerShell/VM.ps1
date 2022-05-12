param ($prefix, $location, $vnet_CIDR, $subnet_CIDR, $publisher, $offer, $sku, $vmSize, $osDiskType, $adminUserName, $Password)

$resourceGroup = "$prefix-Rsg" 
$vNetName = "$prefix-Vnet"
$subnetName = "$vNetName-subnet1"
$nsgName = "$vNetName-nsg1"
$vmName = "$prefix-vm1" 
$pipName = "$vmName-pip"
$nicName = "$vmName-nic"
$osDiskName = "$vmName-OsDisk"

#to create a resource group
New-AzResourceGroup -Name $resourceGroup -Location $location

#create a virtual network
$vNetwork = New-AzVirtualNetwork -ResourceGroupName $resourceGroup -Name $vNetName -AddressPrefix $vnet_CIDR -Location $location

#adding a subnet to vnet
Add-AzVirtualNetworkSubnetConfig -Name $subnetName -VirtualNetwork $vNetwork -AddressPrefix $subnet_CIDR

#Updates a virtual network.
Set-AzVirtualNetwork -VirtualNetwork $vNetwork

#creating a nsg rule and using this to create a NSG
$nsgRuleToVMAccess = New-AzNetworkSecurityRuleConfig -Name 'allow-vm-access' -Protocol Tcp -Direction Inbound -Priority 100 -SourceAddressPrefix * -SourcePortRange * -DestinationAddressPrefix * -DestinationPortRange 22, 3389 -Access Allow
New-AzNetworkSecurityGroup -ResourceGroupName $resourceGroup -Location $location -Name $nsgName -SecurityRules $nsgRuleToVMAccess

#varibales required for configuration of a VM
$vNet = Get-AzVirtualNetwork -ResourceGroupName $resourceGroup -Name $vNetName

$Subnet = Get-AzVirtualNetworkSubnetConfig -Name $subnetName -VirtualNetwork $vNet
$nsg = Get-AzNetworkSecurityGroup -ResourceGroupName $resourceGroup -Name $nsgName

#create admin credentials
$adminPassword = ConvertTo-SecureString $Password -AsPlainText -Force
$cred = New-Object System.Management.Automation.PSCredential ($adminUserName, $adminPassword)

#create a Public Ip
$pip = New-AzPublicIpAddress -Name $pipName -ResourceGroupName $resourceGroup -Location $location -AllocationMethod Static

#create a Network Interface
$nic = New-AzNetworkInterface -Name $nicName -ResourceGroupName $resourceGroup -Location $location -SubnetId $Subnet.Id -PublicIpAddressId $pip.Id -NetworkSecurityGroupId $nsg.Id
$vmConfig = New-AzVMConfig -VMName $vmName -VMSize $vmSize

Add-AzVMNetworkInterface -VM $vmConfig -Id $nic.Id
Set-AzVMOperatingSystem -VM $vmConfig -Windows -ComputerName $vmName -Credential $cred
Set-AzVMSourceImage -VM $vmConfig -PublisherName $publisher -Offer $offer -Skus $sku -Version 'latest'
Set-AzVMOSDisk -VM $vmConfig -Name $osDiskName -DiskSizeInGB 130 -StorageAccountType $osDiskType -CreateOption fromImage
New-AzVM -ResourceGroupName $resourceGroup -Location $location -VM $vmConfig