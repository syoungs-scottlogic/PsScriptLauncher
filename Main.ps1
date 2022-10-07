$introText = @"
  _____   __  ____   ____  ____  ______      _       ____  __ __  ____     __  __ __    ___  ____  
 / ___/  /  ]|    \ l    j|    \|      T    | T     /    T|  T  T|    \   /  ]|  T  T  /  _]|    \ 
(   \_  /  / |  D  ) |  T |  o  )      |    | |    Y  o  ||  |  ||  _  Y /  / |  l  | /  [_ |  D  )
 \__  T/  /  |    /  |  | |   _/l_j  l_j    | l___ |     ||  |  ||  |  |/  /  |  _  |Y    _]|    / 
 /  \ /   \_ |    \  |  | |  |    |  |      |     T|  _  ||  :  ||  |  /   \_ |  |  ||   [_ |    \ 
 \    \     ||  .  Y j  l |  |    |  |      |     ||  |  |l     ||  |  \     ||  |  ||     T|  .  Y
  \___j\____jl__j\_j|____jl__j    l__j      l_____jl__j__j \__,_jl__j__j\____jl__j__jl_____jl__j\_j

"@

    ###  Global Variables ###
$hashTable = New-Object System.Collections.ArrayList
[int]$instanceChoice = 0 
$profileName = "default"
$bucket = "sy-scriptlaunchtest"

    ### Code initialisations ###
Write-Host $introText -BackgroundColor Black -ForegroundColor green
$newItems = New-Object System.Collections.ArrayList
$awsObj = Get-Content "C:\users\syoungs\awstext.txt"  #aws ec2 describe-instances --profile sl --query 'Reservations[*].Instances[*].[InstanceId, Tags[?Key==`Name`].Value | [0]]' --output text

$newItems.Add($awsObj) | Out-Null
$awsObj | foreach{$newItems = $_.split();  $hashTable.Add(@{"$($newItems[1])"="$($newItems[0])"}) | Out-Null}

    #>> Get AWS Profile <<#
$myProfile = read-Host "Please enter an AWS profile. (Default is $($profileName))"
Write-Host ""
if(-not ([string]::IsNullOrEmpty($myProfile)))
{
    $profileName = $myProfile
}


    ### Functions ###
function ListInstances()
{
    Write-Host "Available instances:`n" -ForegroundColor green
    $i = 1
    foreach($item in $hashTable)
    {        
        Write-host "$($i). $($item.keys) ||| $($item.values)"
        $i++
    }

    do{[int]$check = Read-Host "`nPlease select an option"}
    while($check -lt 0 -or $check -gt $i)
    $check--
    $instanceChoice = $check
    Clear-Host

    ListInstanceScripts
    
}

function ListInstanceScripts()
{ 
    $dir = Get-ChildItem .\sh-scripts -Name
    $scripts = New-Object System.Collections.ArrayList
    Write-Host "Available scripts for $($hashTable[$instanceChoice].keys) ($($hashTable[$instanceChoice].Values)):`n"
    [int]$i = 1
    foreach($d in $dir)
    {
        $scripts.Add($d) | Out-Null
        Write-Host "$($i). $($d)"
        $i++
    }
    do {[int]$scriptCheck = Read-Host "`nPlease select a script to run"}
    while($scriptCheck -lt 0 -or $scriptCheck -gt $i)

    $scriptCheck--
    
    do
    {
        $exeCheck = Read-Host "`nAre you sure you would like to execute $($scripts[$scriptCheck]) against $($hashTable[$instanceChoice].Keys) ($($hashTable[$instanceChoice].Values))? y/n"
        $exeCheck.ToLower()
    } while ($exeCheck -notin 'y', 'n')

    switch($exeCheck) {
        'y' {
            PutInS3($scripts[$scriptCheck])
        }
        'n' {
        Clear-Host
        ListInstances
        }
    }
}

function PutInS3($scriptToPush) # RENAME THIS (and its call above)
{
    $dir = Get-ChildItem .\sh-scripts -Name
    foreach($d in $dir)
    {
        try
        {
            if($d -eq $scriptToPush)
            {
            aws s3api put-object --bucket $bucket --key "$($hashTable[$instanceChoice].Values)/$($scriptToPush)" --body ".\sh-scripts\$($scriptToPush)"  --profile $profileName
            }
        } catch {
        Write-Host $_
        Read-Host "`nAn error occured. Please check the above error and press enter to quit."
        }
    }

}


    ### Entry ###
ListInstances


<#

    A small script on eact instance polls the their own folder.
    The instance pulls down the script and runs it. 

    have each folder for instance ID, then I can match it from this script.
    Have the bucket as a variable to quickly swap between clients. 

#>