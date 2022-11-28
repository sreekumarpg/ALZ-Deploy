$LogSubscriptionId="cae48dfb-969c-4f68-85fe-5ca149e5004f"
$LogResourcegroup="rg-iga-log-01"
$LogVNet="vnet-iga-log-01"
$LogAddressPrefix="10.10.24.0/21"
$LogSubnet1="snet-iga-log-app1-01"
$LogSubnet1Prefix="10.10.24.0/24"
$LogSubnet1NSG="nsg-iga-log-app1-01"
$LogPeername="peer-iga-log-01"
$workspaceName="law-iga-log-01"



#----------------------------------------------------------------------------------------#
$location="northeurope"
#----------------------------------------------------------------------------------------#

Select-AzSubscription -SubscriptionId $logSubscriptionId | Out-null
New-AzResourceGroup -Name $LogResourcegroup -Location $location | Out-null

Start-Sleep -Seconds 5

Write-Host "Starting the deployment of Log Analytics Workspace.........." -ForegroundColor DarkGray
Select-AzSubscription -SubscriptionId $LogSubscriptionId  | Out-null
New-AzOperationalInsightsWorkspace -Location $location -Name $workspaceName -Sku pergb2018 -ResourceGroupName $LogResourcegroup | Out-null
Write-Host "Completed the deployment of Log Analytic Workspace" -ForegroundColor DarkGray
Start-Sleep -Seconds 5
Write-Host "Adding Solution to Log Analytic Workspace" -ForegroundColor DarkGray
Start-Sleep -Seconds 5
Register-AzResourceProvider -ProviderNamespace Microsoft.OperationsManagement | Out-null

$workspace = Get-AzOperationalInsightsWorkspace -ResourceGroupName $LogResourcegroup -Name $workspaceName
Set-AzOperationalInsightsIntelligencePack -ResourceGroupName $LogResourcegroup -WorkspaceName $workspaceName -IntelligencePackName Updates -Enabled $true | Out-null
Set-AzOperationalInsightsIntelligencePack -ResourceGroupName $LogResourcegroup -WorkspaceName $workspaceName -IntelligencePackName AzureActivity -Enabled $true | Out-null
Set-AzOperationalInsightsIntelligencePack -ResourceGroupName $LogResourcegroup -WorkspaceName $workspaceName -IntelligencePackName ChangeTracking -Enabled $true | Out-null
Set-AzOperationalInsightsIntelligencePack -ResourceGroupName $LogResourcegroup -WorkspaceName $workspaceName -IntelligencePackName VMInsights -Enabled $true | Out-null
Set-AzOperationalInsightsIntelligencePack -ResourceGroupName $LogResourcegroup -WorkspaceName $workspaceName -IntelligencePackName AntiMalware -Enabled $true | Out-null
Write-Host "Completed the deployment of Log Analytic Workspace" -ForegroundColor Green


Start-Sleep -Seconds 5
Write-Host "Starting the deployment of Log Virtual Network..........." -ForegroundColor DarkGray

Select-AzSubscription -SubscriptionId $logSubscriptionId | Out-null
$L_rule1 = New-AzNetworkSecurityRuleConfig -Name "Inbound_Any_Temp" -Description "Allow Inbound Temp Rule" -Access Allow -Protocol "*" -Direction Inbound -Priority 100 -SourceAddressPrefix "*" -SourcePortRange "*" -DestinationAddressPrefix "*" -DestinationPortRange "*"
$LogSecurityGroup1 = New-AzNetworkSecurityGroup -ResourceGroupName $LogResourcegroup -Location $location -Name $LogSubnet1NSG -SecurityRules $L_rule1

$L_Subnet1 = New-AzVirtualNetworkSubnetConfig -Name $LogSubnet1 -AddressPrefix $LogSubnet1Prefix -NetworkSecurityGroup $LogSecurityGroup1
New-AzVirtualNetwork -Name $LogVNet -ResourceGroupName $LogResourcegroup -Location $location -AddressPrefix $LogAddressPrefix -Subnet $L_Subnet1 | Out-null
Write-Host "Completed the deployment of Log Network" -ForegroundColor Green