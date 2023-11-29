$RoleName = 'SendMailLambdaRole'
$InstanceProfileName = 'NanaSSM'
$KeyPairName = 'reInvent2023TestKeyPai'
#ami id - us-east-1
$WindowsAmidId = 'ami-0cd601a22ac9e6d79'
#VPC ID for us-east-1
#$VpcId = 'vpc-9920dce0'
#VPC ID for eu-central-1
# NOTE: replace with VPC id from your account
$VpcId = 'vpc-9920dce0'
$SNSTopicName = 'arn:aws:sns:us-east-1:675675802741:Automation-NanaTestApproval'
$EnvironmentStack = 'DemoEnvironmentReInvent2023'
$AlarmName = 'NanaDemoAlarm'
$RuleName = 'NanaTestRule'

$SimpleRunbook = 'Nana-ResizeInstanceSimple'
$BranchingRunbook = 'Nana-ResizeInstanceBranching'
$AdvancedRunbook = 'Nana-ResizeInstanceAdvanced'
<#$GetCredentialDoc = 'Nana-GetCredentialFromStore'
$RestartServiceCommandDoc = 'Nana-RestartServiceCommand'
$RestartWindowsUpdateDoc = 'Nana-RestartWindowsUpdate'
$CopyS3FolderDoc = 'Nana-CopyS3Folder'
$ApplyDscMof = 'Nana-ApplyDSCMofs-20190513'
$DisableTabletInput = 'Nana-DisableTabletInputService'
#>