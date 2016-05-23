$Dir = Get-FolderItem -Path '\\folder\folder'
$List = $Dir | where {$_.name -like "*.pst"}
$List | ft fullname,lastwritetime,@{Name="Mbytes";Expression={ "{0:N0}" -f ($_.Length / 1Mb)}} -wrap
$Result = $List | Measure-Object -Property length -sum
$Result | fl Count,@{Name="Gbytes";Expression={ "{0:N0}" -f ($_.Sum / 1Gb)}},property
