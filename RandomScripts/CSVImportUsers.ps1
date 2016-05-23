
param (

    [string]$Path

    )

add-pssnapin Microsoft.Exchange.Management.PowerShell.E2010
Import-Module activedirectory

$Users = Import-Csv -Path $Path
foreach ($User in $Users)
{

    $Firstname = $User.'First Name'
    $LastName = $User.'Last Name'
    $DisplayName = $User.'First Name' + " " + $User.'Last Name'
    $Title = $User.'Title / Position'
    $Location = $User.'Location'
    $Street = $User.'Street'
    $City = $User.'City'
    $State = $User.'State'
    $Zip = $User.'Zip'
    $EmailAddress = $User.'Email Address'
    $UPN = $User.'Email Address'
    $samAccountName = $User.'SAM Account Name'
    $OU = $User.'OU'
    $ProfilePath = $User.'Profile Path'
    $HomeDir = $User.'Home Directory'
    $Password = $User.'Password'
    $MailboxDB = $User.'Mailbox Database'
    $X500 = $User.'legacyExchangeDN'

    New-Mailbox -Name $DisplayName -FirstName $Firstname -LastName $LastName -PrimarySmtpAddress $EmailAddress -Database $MailboxDB -UserPrincipalName $UPN -OrganizationalUnit $OU -SamAccountName $samAccountName -Password (ConvertTo-SecureString -String $Password -AsPlainText -Force)
    
    Set-ADUser $samAccountName -Office $Location -Title $Title -StreetAddress $Street -City $City -State $State -PostalCode $Zip -HomeDrive "Z:" -HomeDirectory $HomeDir 

    if ($X500){

    Set-ADUser $samAccountName -Add @{proxyAddresses=$X500}

    }
    else{}

    Get-ADUser $samAccountName | ForEach-Object {
        $ADSI = [ADSI]('LDAP://{0}' -f $_.DistinguishedName)
        $ADSI.InvokeSet('TerminalServicesProfilePath',$ProfilePath)
        $ADSI.InvokeSet("TerminalServicesHomeDrive","Z:")
        $ADSI.InvokeSet("TerminalServicesHomeDirectory",$HomeDir) 
        $ADSI.SetInfo()
    }

}

