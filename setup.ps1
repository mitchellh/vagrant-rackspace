Function SetupWinRM
{
  Param(
    [String]$hostname,
    [String]$thumbprint
   )
  netsh advfirewall firewall set rule group="remote administration" new enable=yes
  netsh advfirewall firewall add rule name="WinRM HTTP" dir=in action=allow protocol=TCP localport=5985
  netsh advfirewall firewall add rule name="WinRM HTTPS" dir=in action=allow protocol=TCP localport=5986
  winrm create winrm/config/Listener?Address=*+Transport=HTTPS "@{Hostname=`"${hostname}`"; CertificateThumbprint=`"${thumbprint}`"}"
}

$hostname = $env:COMPUTERNAME
$cert = New-SelfSignedCertificate -CertStoreLocation cert:\LocalMachine\My -DnsName $hostname
$thumbprint = $cert.Thumbprint
SetupWinRM -hostname $hostname -thumbprint $thumbprint
