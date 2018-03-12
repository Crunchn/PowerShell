<#
Requirements:
    This script requires the MSOnline module.
    PS> Import-Module MSOnline
    PS> Connect-MsolService

Description:
    Convert the default(Primary) domain to a variable(ending at period or dash) and assigns TenantId to the variable.

Example:
    domain1234.com
    $domain1234 = <TenantId>

    domain123.onmicrosoft.com
    $domain123 = <TenantId>

    example1-domain.com
    $example1 = <TenantId>

Contributors:
    Christian Batten

#>

$TenantId = Get-MsolPartnerContract -ALL

foreach ($Tenant in $TenantId)
{
    $Domain = $Tenant | Get-MsolDomain | Where {$_.IsDefault -eq $true}
    $TenSplit = $Domain.Name.Split(".-")[0]
    $Value = $Tenant | Select TenantId | ft -HideTableHeaders | Out-String

    New-Variable -Name $TenSplit -Value $Value -Force
    Get-Variable -Name $TenSplit -ValueOnly
}