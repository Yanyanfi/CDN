Push-Location $PSScriptRoot
$domainSuffixPattern = "\s*- '\+\.(.+)'";
$domainPattern = "\s*- '([^\+]*)'"
$clashGfw =  
Invoke-WebRequest -Uri https://gl.bbkss.org/https://raw.githubusercontent.com/Loyalsoldier/clash-rules/release/gfw.txt -Method Get
| Select-Object -ExpandProperty Content
| ForEach-Object { $_ -split "`n" }

$clashDirect = 
Invoke-WebRequest -Uri https://gl.bbkss.org/https://raw.githubusercontent.com/Loyalsoldier/clash-rules/release/direct.txt -Method Get
| Select-Object -ExpandProperty Content
| ForEach-Object { $_ -split "`n" }
function  Write-LoonRules {
    param (
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [string]$Path,
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        $ClashRuleSet
    )
    $ClashRuleSet
    | ForEach-Object {
        if ($_ -match $domainPattern) {
            $_ -replace $domainPattern, 'DOMAIN,$1'
        }
        elseif ($_ -match $domainSuffixPattern) {
            $_ -replace $domainSuffixPattern, 'DOMAIN-SUFFIX,$1'
        }
    }
    | Out-File $Path
}
Write-LoonRules -Path .\GFW_Loon -ClashRuleSet $clashGfw
Write-LoonRules -Path .\SuperDirect_Loon -ClashRuleSet $clashDirect
git add .
git commit -m "update loon rules"
git push

