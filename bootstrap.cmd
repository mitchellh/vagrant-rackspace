netsh advfirewall firewall set rule group="remote administration" new enable=yes
netsh advfirewall firewall add rule name="WinRM HTTP" dir=in action=allow protocol=TCP localport=5985
# Setup winrm via SSL
# "%PROGRAMFILES%\Microsoft SDKs\Windows\v7.1\Bin\makecert.exe" -sk %COMPUTERNAME% -ss my -sr LocalMachine -r -n "CN=%COMPUTERNAME%" -a sha1 -eku "1.3.6.1.5.5.7.3.1"
# This needs to be powersell, and we need to get the thumbprint from the output :\
# ls cert://localmachine/my
# winrm set winrm/config/listener?Address=IP:0.0.0.0+Transport=HTTPS @{Hostname="%COMPUTERNAME%";CertificateThumbprint="%MYCERTTHUMBPRINT%";Port="5986"}
# netsh advfirewall firewall add rule name="WinRM HTTPS" dir=in action=allow protocol=TCP localport=5986
