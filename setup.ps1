netsh advfirewall firewall set rule group="remote administration" new enable=yes
netsh advfirewall firewall add rule name="WinRM HTTP" dir=in action=allow protocol=TCP localport=5985
netsh advfirewall firewall add rule name="WinRM HTTPS" dir=in action=allow protocol=TCP localport=5986
iex ((new-object net.webclient).DownloadString('https://chocolatey.org/install.ps1'))
cinst SelfSSL7
selfssl7 /N:CN=$env:computername /T
$thumbprint = Get-ChildItem cert:\LocalMachine\Root\ | where{$_.Subject -eq "CN=${env:computername}"} | Select -first 1 -expand Thumbprint
winrm create winrm/config/Listener?Address=*+Transport=HTTPS "@{Hostname=`"${env:computername}`"; CertificateThumbprint=`"${thumbprint}`"}"
