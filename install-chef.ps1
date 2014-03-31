$webclient = New-Object System.Net.WebClient
$webclient.DownloadFile("https://opscode-omnibus-packages.s3.amazonaws.com/windows/2008r2/x86_64/chef-client-11.10.4-1.windows.msi", "chef.msi")
msiexec /passive /i $PWD\chef.msi
