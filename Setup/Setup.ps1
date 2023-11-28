[CmdletBinding()]
param(
)

. "./Settings.ps1"

$AllStacks = @($EnvironmentStack)
function Get-Parameter
{
	param(
		[Parameter(Position=0)]
		[string]
		$Key,

		[Parameter(Position=1)]
		[string]
		$Value
	)
	$Param = New-Object Amazon.CloudFormation.Model.Parameter
	$Param.ParameterKey = $Key
	$Param.ParameterValue = $Value
	
	return $Param
}

function Wait-Stack
{
	param(
		[string]
		$StackName
	)
	$Status = (Get-CFNStack -StackName $StackName).StackStatus
	
	while ($Status -ne 'CREATE_COMPLETE'){
		Write-Verbose "Waiting for stack creation to complete  $StackName"
		Start-Sleep -Seconds 5
		$Status = (Get-CFNStack -StackName $StackName).StackStatus
	}
}

# create the cloud formation stacks
$contents = Get-Content ./CloudFormationTemplates/Environment.yml -Raw
$Role = Get-Parameter 'RoleName' $RoleName
$LambdaFunction = Get-Parameter 'FunctionName' $LambdaFunctionName
$InstanceProfile = Get-Parameter 'InstanceProfileName' $InstanceProfileName
$KeyPair = Get-Parameter 'KeyPairName' $KeyPairName
$AmiId = Get-Parameter 'AmiId' $WindowsAmidId
$Vpc = Get-Parameter 'VpcId' $VpcId
$SNSTopic = Get-Parameter 'SNSTopicName' $SNSTopicName
$CloudWatchAlarm = Get-Parameter 'AlarmName' $AlarmName
$EventBridgeRule = Get-Parameter 'EventBridgeRuleName' $RuleName

New-CFNStack -StackName $EnvironmentStack -TemplateBody $contents -Parameter @($InstanceProfile, $KeyPair, $AmiId, $Vpc, $Role, $LambdaFunction, $SNSTopic, $CloudWatchAlarm, $EventBridgeRule) -Capability CAPABILITY_NAMED_IAM

# wait for the stack creation to complete
$AllStacks | %{
	Wait-Stack -StackName $_
}

$Runbooks = @($SimpleRunbook, $BranchingRunbook, $AdvancedRunbook)

$Runbooks | %{
	$contents = Get-Content "../Runbooks/$($_).yml" -Raw
	New-SSMDocument -Content $contents -DocumentFormat YAML -DocumentType Automation -Name $_
}

<#$CommandDocs = @($RestartWindowsUpdateDoc, $RestartServiceCommandDoc, $CopyS3FolderDoc, $GetCredentialDoc, $ApplyDscMof, $DisableTabletInput)

$CommandDocs | % {
	$contents = Get-Content "../Documents/$($_).yml" -Raw
	New-SSMDocument -Content $contents -DocumentFormat YAML -DocumentType Command -Name $_ 
}

# Wait to ensure all managed instances show up
$WaitTime = 1
while(1){
	$Count = (Get-SSMInstanceInformation | measure).Count                                    
	if ($Count -eq 5){break}
	Write-Verbose "Waiting $WaitTime seconds for managed instances to show up"
	Start-Sleep 1
	$WaitTime++
}

# copy bakery website to the instances created
$Target = New-Object Amazon.SimpleSystemsManagement.Model.Target          
$Target.Key = 'tag:Type'                                                  
$Target.Values = @('Webserver') 

$Parameters = @{
	"BucketName" = 'psconfeu2019'
	"FolderName" = 'Content'
	"LocalPath" = 'C:\Content'
}
$CommandId = (Send-SSMCommand -DocumentName $CopyS3FolderDoc -Target $Target -Parameter $Parameters).CommandId

while(1){$Status = (Get-SSMCommandInvocation -CommandId $CommandId).Status;if ($Status -eq 'Success'){break;} sleep 2}              

# Create SSM Parameter Store entries
# Note: Secure string cannot be created using a cloud formation template
Write-SSMParameter -Name "DBString" -Description "DB string for connection" -Type String -Value "server=myserver.dns.domain"
Write-SSMParameter -Name "DBPassword" -Description "DB Password" -Type SecureString -Value "TestPassword"

# Create SSM Parameter Store Entries for website configuration
Write-SSMParameter -Name "LogPath" -Description "Logpath for IIS" -Type String -Value "C:\IISLog" 
Write-SSMParameter -Name "WebSiteDestinationPath" -Description "Path for website destination" -Type String -Value 'C:\inetpub\FourthCoffee'
Write-SSMParameter -Name "WebSiteName" -Description "Name of website" -Type String -Value 'FourthCoffee'

#>