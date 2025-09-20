# Powershell

Invoke-Expression (New-Object System.Net.WebClient).DownloadString('https://get.scoop.sh')
scoop bucket add extras
scoop install nsis

$mainDir = Get-Location
echo $mainDir

mkdir build
cd build
mkdir installs

cmake -G "MinGW Makefiles" -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=installs ../

mingw32-make -j4

mingw32-make install

echo "--- Building installer"
makensis installs/bin/metronomek.nsi

cd ..
