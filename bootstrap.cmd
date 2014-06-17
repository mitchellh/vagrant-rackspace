set dir="%~dp0"
echo "I was run" > bootstrap.log
pushd %dir%
ren setup.txt setup.ps1
@powershell -NoProfile -ExecutionPolicy unrestricted -File setup.ps1 > setup.log
popd
