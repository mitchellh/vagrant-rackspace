netsh advfirewall firewall set rule group="remote administration" new enable=yes
netsh advfirewall firewall add rule name="WinRM HTTP" dir=in action=allow protocol=TCP localport=5985
ren C:\cloud-automation\install-chef.cmd install-chef.ps1
@powershell -NoProfile -ExecutionPolicy unrestricted -File C:\cloud-automation\install-chef.ps1
@powershell -NoProfile -ExecutionPolicy unrestricted -Command "iex ((new-object net.webclient).DownloadString('https://chocolatey.org/install.ps1'))" && SET PATH=%PATH%;%systemdrive%\chocolatey\bin
