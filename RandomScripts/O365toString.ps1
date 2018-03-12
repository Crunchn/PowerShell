$TenantId = Get-MsolPartnerContract -ALL

foreach ($Tenant in $TenantId)
{
    $Domain = $Tenant | Get-MsolDomain | Where {$_.IsDefault -eq $true}
    $TenSplit = $Domain.Name.Split(".-")[0]
    $Value = $Tenant | Select TenantId | ft -HideTableHeaders | Out-String

    New-Variable -Name $TenSplit -Value $Value -Force
    Get-Variable -Name $TenSplit -ValueOnly
}