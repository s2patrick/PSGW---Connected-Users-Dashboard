# Script can be used in SCOM 2012 R2 UR2 (or newer) Dashboards using PowerShell Grid Widget
#
# Author:  Patrick Seidl
# Company: Syliance IT Services
# Website: www.syliance.com
# Blog:    www.SystemCenterRocks.com
#
# Please rate if you like it:
# https://gallery.technet.microsoft.com/systemcenter/PSGW-Connected-Users-20817b14

if(-not (Get-Module | Where-Object {$_.Name -eq "ActiveDirectory"})) {
	Import-Module ActiveDirectory
}
if (Get-Module ActiveDirectory) {$adModule = $true}

foreach ($MS in (Get-SCOMManagementServer)) {
    if ($MS.IsGateway -eq $false) {
        $MG = Get-SCOMManagementGroup -ComputerName $MS.PrincipalName
        $users = $MG.GetConnectedUserNames() | select @{name="Account";expression={$_}},@{name="LastUpdate";expression={get-date}}
 
        foreach ($user in $users) {
            $dataObject = $ScriptContext.CreateInstance("xsd://foo!bar/baz")
            $dataObject["Id"] = [String]($user.Account + "@" + $MS.ComputerName)
            $dataObject["Account"] = [String]($user.Account)
            if ($adModule -eq $true) {
                $dataObject["Display Name"] = [String](((Get-ADUser $user.account.split("\")[1] -properties DisplayName).DisplayName))
                $dataObject["Management Server"] = ($MS.ComputerName)
            } else {
                $dataObject["Display Name"] = [String]("")
                $dataObject["Note"] = [String]("Please install RSAT Feature")
            }
            $dataObject["Last Update"] = [String]($user.LastUpdate)
    	    #if ($error) {
    	    #	$dataObject["Error"] = [String]($error)
    	    #	$error.clear()
    	    #}
            $ScriptContext.ReturnCollection.Add($dataObject)
        }
    }
}