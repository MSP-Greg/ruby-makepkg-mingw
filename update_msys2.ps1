#———————————————————————————————————————————————————————————————————— Check-Exit
# checks whether to exit
function Check-Exit($msg, $pop) {
  if ($LastExitCode -and $LastExitCode -ne 0) {
    if ($pop) { Pop-Location }
    Write-Host $msg -ForegroundColor $fc
    exit 1
  }
}

$base_path  = 'C:\WINDOWS\system32;C:\WINDOWS;C:\WINDOWS\System32\Wbem;'
$base_path += 'C:\WINDOWS\System32\WindowsPowerShell\v1.0\;C:\Program Files\Git\cmd;'
$base_path += 'C:\Program Files\7-Zip;C:\Program Files\AppVeyor\BuildAgent'
$dash = "$([char]0x2015)"
$fc   = 'Yellow'

$base_name, $bits = $args[0].Split(' ')

if ( !($bits -eq '32' -or $bits -eq '64') ) {
  Write-Host $bits must be 32 or 64!
  exit 1
}

$m_pre = if ($bits -eq '64') {
  $env:path = "C:\msys64\mingw64\bin;C:\msys64\usr\bin;$base_path"
  'mingw-w64-x86_64-'
} else {
  $env:path = "C:\msys64\mingw32\bin;C:\msys64\usr\bin;$base_path"
  'mingw-w64-i686-'
}

# Only use below for really outdated systems, as it wil perform a full update
# for 'newer' systems...
Write-Host "$($dash * 65) Updating MSYS2 / MinGW -Syu" -ForegroundColor $fc
Write-Host "pacman.exe -Syu --noconfirm --needed --noprogressbar" -ForegroundColor $fc
pacman.exe -Syu --noconfirm --needed --noprogressbar
Check-Exit 'Cannot update with -Syu'

Write-Host "$($dash * 65) Updating MSYS2 / MinGW base" -ForegroundColor $fc
Write-Host "pacman.exe -Sd --noconfirm --needed --noprogressbar base" -ForegroundColor $fc
# change to -Syu if above is commented out
pacman.exe -Sd --noconfirm --needed --noprogressbar base 2> $null
Check-Exit 'Cannot update base'

Write-Host "$($dash * 65) Updating MSYS2 / MinGW base-devel" -ForegroundColor $fc
Write-Host "pacman.exe -S --noconfirm --needed --noprogressbar base-devel" -ForegroundColor $fc
pacman.exe -S --noconfirm --needed --noprogressbar base-devel 2> $null
Check-Exit 'Cannot update base-devel'

Write-Host "$($dash * 65) Updating gnupg `& depends" -ForegroundColor $fc

Write-Host "Updating gnupg extended dependencies" -ForegroundColor Yellow
#pacman.exe -S --noconfirm --needed --noprogressbar brotli ca-certificates glib2 gmp heimdal-libs icu libasprintf libcrypt
#pacman.exe -S --noconfirm --needed --noprogressbar libdb libedit libexpat libffi libgettextpo libhogweed libidn2 liblzma
pacman.exe -S --noconfirm --needed --noprogressbar libmetalink libnettle libnghttp2 libopenssl libp11-kit libpcre libpsl 2> $null
#pacman.exe -S --noconfirm --needed --noprogressbar libssh2 libtasn1 libunistring libxml2 libxslt openssl p11-kit 

Write-Host "Updating gnupg package dependencies" -ForegroundColor Yellow
# below are listed gnupg dependencies
pacman.exe -S --noconfirm --needed --noprogressbar bzip2 libassuan libbz2 libcurl libgcrypt libgnutls libgpg-error libiconv 2> $null
pacman.exe -S --noconfirm --needed --noprogressbar libintl libksba libnpth libreadline libsqlite nettle pinentry zlib 2> $null

Write-Host "Updating gnupg" -ForegroundColor Yellow
pacman.exe -S --noconfirm --needed --noprogressbar gnupg 2> $null

Write-Host "$($dash * 65) Updating MSYS2 / MinGW toolchain" -ForegroundColor $fc
Write-Host "pacman.exe -S --noconfirm --needed --noprogressbar $($m_pre + 'toolchain')" -ForegroundColor $fc
pacman.exe -S --noconfirm --needed --noprogressbar $($m_pre + 'toolchain') 2> $null
Check-Exit 'Cannot update toolchain'
