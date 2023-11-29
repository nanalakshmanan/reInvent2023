[CmdletBinding()]
param(
)
. "./Settings.ps1"

$AllStacks = @($EnvironmentStack)
function Wait-Stack
{
	param(
		[string]
		$StackName
	)
	while(Test-CFNStack -StackName $StackName){
		Write-Verbose "Waiting for Stack $StackName to be deleted"
		Start-Sleep -Seconds 3
	}
}
$AllStacks | % {
	if (Test-CFNStack -StackName $_){
		Remove-CFNStack -StackName $_ -Force
	}
}

$AllStacks | % {
	Wait-Stack -StackName $_
}

$Runbooks = @($SimpleRunbook, $BranchingRunbook, $AdvancedRunbook, $ScriptRunbook)

$Runbooks | %{
	Remove-SSMDocument -Name $_ -Force
}

<#$CommandDocs = @($RestartWindowsUpdateDoc, $RestartServiceCommandDoc, $CopyS3FolderDoc, $GetCredentialDoc, $ApplyDscMof, $DisableTabletInput)

$CommandDocs | % {
	Remove-SSMDocument -Name $_ -Force
}

# Remove SSM Parameters
Remove-SSMParameter -Name "DBString" -Force
Remove-SSMParameter -Name "DBPassword" -Force
Remove-SSMParameter -Name "LogPath" -Force
Remove-SSMParameter -Name "WebSiteName" -Force
Remove-SSMParameter -Name "WebSiteDestinationPath" -Force

# Remove associations
Get-SSMAssociationList | foreach AssociationId | %{Remove-SSMAssociation -AssociationId $_ -Force}
#>
