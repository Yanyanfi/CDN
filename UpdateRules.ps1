param(
    [switch]$MyRules,
    [switch]$RemoteRules,
    [switch]$Local
)
Import-Module 'C:\Projects\clash_configration\ClashConfig.psm1'
Push-Location $PSScriptRoot
$domainSuffixPattern = "\s*- '\+\.(.+)'"
$domainPattern = "\s*- '([^\+]*)'"
$lDomainPattern = "\s*- DOMAIN,([^\+]*)"
$lDomainSuffixPattern = "\s*- DOMAIN-SUFFIX,([^\+]*)"
$lDomainKeywordPattern = "\s*- DOMAIN-KEYWORD,([^\+]*)"
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
        elseif ($_ -match $lDomainPattern) {
            $_ -replace $lDomainPattern, 'DOMAIN,$1'
        }
        elseif ($_ -match $lDomainSuffixPattern) {
            $_ -replace $lDomainSuffixPattern, 'DOMAIN-SUFFIX,$1'
        }
        elseif ($_ -match $lDomainKeywordPattern) {
            $_ -replace $lDomainKeywordPattern, 'DOMAIN-KEYWORD,$1'
        }
    }
    | Out-File $Path
}

if ($RemoteRules) {
    $clashGfw =  
    Invoke-WebRequest -Uri https://gl.bbkss.org/https://raw.githubusercontent.com/Loyalsoldier/clash-rules/release/gfw.txt -Method Get
    | Select-Object -ExpandProperty Content
    | ForEach-Object { $_ -split "`n" }

    $clashDirect = 
    Invoke-WebRequest -Uri https://gl.bbkss.org/https://raw.githubusercontent.com/Loyalsoldier/clash-rules/release/direct.txt -Method Get
    | Select-Object -ExpandProperty Content
    | ForEach-Object { $_ -split "`n" }

    Write-LoonRules -Path .\GFW_Loon -ClashRuleSet $clashGfw
    Write-LoonRules -Path .\SuperDirect_Loon -ClashRuleSet $clashDirect
}
if($MyRules){
    $clashDirect = Get-Content .\Direct
    $clashProxy = Get-Content .\Proxy
    $clashSpecialProxy = Get-Content .\SpecialProxy
    Write-LoonRules -Path .\Direct_Loon -ClashRuleSet $clashDirect
    Write-LoonRules -Path .\Proxy_Loon -ClashRuleSet $clashProxy
    Write-LoonRules -Path .\SpecialProxy_Loon -ClashRuleSet $clashSpecialProxy
}
git add .
git commit -m "update loon rules"
if (-not $Local) {
    git push    
}
Update-RuleSet -Restart

