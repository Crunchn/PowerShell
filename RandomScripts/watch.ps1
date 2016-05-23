param (

    [int]$n,
    [string]$command

)

while ($true) {
   clear
   Invoke-Expression $command
   sleep $n
}