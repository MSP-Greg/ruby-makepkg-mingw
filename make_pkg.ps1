<#
Code by MSP-Greg
#>

$base_path  = 'C:\WINDOWS\system32;C:\WINDOWS;C:\WINDOWS\System32\Wbem;'
$base_path += 'C:\WINDOWS\System32\WindowsPowerShell\v1.0\;C:\Program Files\Git\cmd;'
$base_path += 'C:\Program Files\7-Zip;C:\Program Files\AppVeyor\BuildAgent'
$dash = "$([char]0x2015)"
$fc   = 'Yellow'

$ks1  = 'hkp://pool.sks-keyservers.net'
$ks2  = 'hkp://pgp.mit.edu'
# Matt Caswell <matt@openssl.org>
$key  = 'D9C4D26D0E604491'

$master = 'openssl-1.1.1-pre9'
$is_master = $false

#——————————————————————————————————————————————————————————————————— Add GPG key
function Add-Key {
  Write-Host "`ntry retrieving key" -ForegroundColor Yellow

  gpg.exe -k 2> $null
  $okay = Retry gpg.exe --keyserver $ks1 --receive-keys $key
  # below is for occasional key retrieve failure on Appveyor
  if (!$okay) {
    Write-Host GPG Key Lookup failed from $ks1 -ForegroundColor Yellow
    # try another keyserver
    $okay = Retry gpg.exe  --keyserver $ks2 --receive-keys $key
    if (!$okay) {
      Write-Host GPG Key Lookup failed from $ks2 -ForegroundColor Yellow
      if ($in_av) {
        Update-AppveyorBuild -Message "keyserver retrieval failed"
      }
      exit 1
    } else { Write-Host GPG Key Lookup succeeded from $ks2 }
  }   else { Write-Host GPG Key Lookup succeeded from $ks1 }
  Write-Host "list keys" -ForegroundColor Yellow
  gpg.exe -k
}

#———————————————————————————————————————————————————————————————————— Check-Exit
# checks whether to exit
function Check-Exit($msg, $pop) {
  if ($LastExitCode -and $LastExitCode -ne 0) {
    if ($pop) { Pop-Location }
    Write-Host $msg -ForegroundColor $fc
    exit 1
  }
}

#————————————————————————————————————————————————————————————————————————— Retry
# retries passed parameters as a command three times
function Retry {
  $err_action = $ErrorActionPreference
  $ErrorActionPreference = "Stop"
  $a = $args[1..($args.Length-1)]
  $c = $args[0]
  # Write-Host $c $a -ForegroundColor $fc
  foreach ($idx in 1..3) {
    $Error.clear()
    try {
      &$c $a # 2> $null
      if ($? -and ($Error.length -eq 0 -or $Error.length -eq $null)) {
        $ErrorActionPreference = $err_action
        return $true
      }
    } catch {
      if (!($Error[0] -match 'fail|error|Remote key not fetched correctly')) {
        $ErrorActionPreference = $err_action
        return $true
      }
    }
    if ($idx -lt 3) {
      Write-Host "  retry"
      Start-Sleep 1
    }
  }
  $ErrorActionPreference = $err_action
  return $false
}

function Setup-Master {
  git clone -q --depth=5 --no-tags --branch=master https://github.com/openssl/openssl.git C:\projects\ruby-makepkg-mingw\mingw-w64-openssl-master\src\$master
}

$base_name, $bits = $args[0].Split(' ')

if ($base_name -match "\Amingw-w64-openssl-1\.1\.0" ) {
  $base_dir = "$PSScriptRoot/mingw-w64-openssl-1.1.0"
} elseif ($base_name -match "\Amingw-w64-openssl-1\.1\.1" ) {
  $base_dir = "$PSScriptRoot/mingw-w64-openssl-1.1.0"
} elseif ($base_name -match "\Amingw-w64-openssl-master" ) {
  $base_dir = "$PSScriptRoot/mingw-w64-openssl-master"
  $is_master = $true
} else {
  Write-Host Incorrect base name $base_name -ForegroundColor $fc
  exit 1
}

if ( !($bits -eq '32' -or $bits -eq '64') ) {
  Write-Host $bits must be 32 or 64!
  exit 1
}

if ( Test-Path -Path $base_dir -PathType Container ) {
  Push-Location $base_dir
} else {
  Write-Host $base_name directory not found!
  exit 1
}

$mingw = if ($bits -eq '64') { 'mingw64' } else { 'mingw32' }

$env:path = "C:\msys64\$mingw\bin;C:\msys64\usr\bin;$base_path"

if ($is_master) { Setup-Master } else { Add-Key }

Write-Host "$($dash * 65) Starting Build" -ForegroundColor $fc
bash.exe -c `"MINGW_INSTALLS=$mingw makepkg-mingw -Lf --noprogressbar`"

Check-Exit 'Package did not build!'

$package = $(Get-ChildItem -Path ./*-any.pkg.tar.xz | Sort-Object -Descending LastWriteTime | select -expand Name)
$log_zip = $package.replace('-any.pkg.tar.xz', '') + "_log_files.7z"

7z.exe a $log_zip .\*.log 1> $null

if ($env:APPVEYOR) {
  Push-AppveyorArtifact $base_dir/$package
  Push-AppveyorArtifact $base_dir/$log_zip
  $msg = "$bits bit package SHA256"
  Add-AppveyorMessage -Message $msg -Details $(CertUtil -hashfile $$package SHA256)
}

Pop-Location
