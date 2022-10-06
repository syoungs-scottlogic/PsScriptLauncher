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

    ### Code initialisations ###
Write-Host $introText -BackgroundColor Black -ForegroundColor green
$newItems = New-Object System.Collections.ArrayList
$awsObj = Get-Content "C:\users\syoungs\awstext.txt"  #aws ec2 describe-instances --profile sl --query 'Reservations[*].Instances[*].[InstanceId, Tags[?Key==`Name`].Value | [0]]' --output text

$newItems.Add($awsObj) | Out-Null
$awsObj | foreach{$newItems = $_.split();  $hashTable.Add(@{"$($newItems[1])"="$($newItems[0])"}) | Out-Null}


    ### Functions ###
function ListInstances()
{
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
    # Here are the available scripts. 
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
        $exeCheck = Read-Host "Are you sure you would like to execute $($scripts[$scriptCheck]) against $($hashTable[$instanceChoice].Keys) ($($hashTable[$instanceChoice].Values))? y/n"
        $exeCheck.ToLower()
    } while ($exeCheck -notin 'y', 'n')

    switch($exeCheck) {
        'y' {
            #Run script
            Write-Host "run script"
        }
        'n' {
        Clear-Host
        ListInstances
        }
    }
        <#
            Are you sure you would like to execute <script> against <instance>?
            execute sctips against instance via AWS CLI
        #>

}

ListInstances




