source 'https://rubygems.org'

group :plugins do
  gemspec
  gem 'vagrant', :git => 'https://github.com/mitchellh/vagrant'
end

gem "appraisal", "1.0.0.beta2"

group :development do
  # We depend on Vagrant for development, but we don't add it as a
  # gem dependency because we expect to be installed within the
  # Vagrant environment itself using `vagrant plugin`.
  gem 'coveralls', require: false
  gem 'pry'
  # Forked: Fog needs to accept admin password on creation
  gem 'fog', :git => 'git@github.com:maxlinc/fog.git', :branch => 'rackspace_admin_pass'
end

