# 0.1.9 (June 24, 2014)

FEATURES:

 - Support for userdata and drive config [GH-100]

 BUG FIXES:

 - Fixed the ability to specify strings and integers for flavors and images in VagrantFile
 
# 0.1.8 (June 20, 2014)

FEATURES:

 - Use new synced folder support found in Vagrant 1.4+ if available [GH-104]
 - Ability to set admin password [GH-105] [GH-107]

IMPROVEMENTS:

 - Copy symlinks when syncing folders using older versions of vagrant [GH-89]
 - Update vagrant to allow users to specify non-standard images and flavors [GH-101]

BUG FIXES:

  - Fixed windows path issue when syncing folders older versions of vagrant [GH-96]


# 0.1.7 (March 13, 2014)

FEATURES:

 - Adds commands to list available images and flavors [GH-73]
 - Adds support for creating images from running VMs [GH-74]

IMPROVEMENTS:

 - Adds support for rsync --include directives [GH-56]
 - Adds ability to add server metadata [GH-72]
 - Cleans up chef node and client from chef server [GH-67]

# 0.1.6 (January 8, 2014)

BUG FIXES:

  - Downgraded fog to 1.18 in order to be more compatible with vagrant-aws
  
# 0.1.5 (January 8, 2014)

IMPROVEMENTS:

  - Fix Vagrant 1.4 compatibility and support multiple SSH keys [GH-58]
  - Add uploaded keypair support [GH-53]
  - Add ssh_run support, for vagrant ssh -c [GH-57]
  - Requires fog 1.19 [GH-65]

BUG FIXES:

  - Remove networks warning as vagrant-rackspace now supports networks [GH-64]

# 0.1.4 (October 15, 2013)

IMPROVEMENTS:

  - Adds endpoint validation (rackspace_compute_url, rackspace_auth_url) [GH-39]
  
FEATURES:
  - Adds ability to configure networks [GH-37]

# 0.1.3 (September 6, 2013)

IMPROVEMENTS:

  - Adds ability to specify authentication endpoint; Support for UK Cloud! [GH-32]
  - Adds ability to specify disk configuration (disk_conf) [GH-33]

# 0.1.2 (August 22, 2013)

FEATURES:

- Add provision support [GH-16]
  
IMPROVEMENTS:
  
  - Adds option to allow provisioning after RackConnect scripts complete. [GH-18]
  - Remove Fog deprecation warnings [GH-11]
  - Bypass rsync's StrictHostKeyCheck [GH-5]
  - Make chown'ing of synced folder perms recursive (for ssh user) [GH-24]
  - Use /cygdrive when rsyncing on Windows [GH-17]
  
  
# 0.1.1 (March 18, 2013)

* Up fog dependency for Vagrant 1.1.1

# 0.1.0 (March 14, 2013)

* Initial release.
