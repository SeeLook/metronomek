# Powershell

Invoke-Expression (New-Object System.Net.WebClient).DownloadString('https://get.scoop.sh')
scoop bucket add extras
scoop install nsis
scoop install wget

$mainDir = Get-Location
echo $mainDir

mkdir build
cd build

cmake -G "MinGW Makefiles" -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=installs ../

mingw32-make -j2

mkdir installs
mingw32-make install
mingw32-make deploy

echo "--- Building installer"
makensis installs/metronomek.nsi

cd ..
