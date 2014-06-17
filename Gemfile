source 'https://rubygems.org'

group :plugins do
  gemspec
  gem 'vagrant', :git => 'https://github.com/mitchellh/vagrant'

  # For unreleased SSL support
  # gem 'vagrant', :git => 'https://github.com/pdericson/vagrant', :branch => 'winrmssl' # https://github.com/WinRb/WinRM/pull/44
  # gem 'winrm', :git => 'https://github.com/WinRb/WinRM' # https://github.com/WinRb/WinRM/pull/44
end

gem "appraisal", "1.0.0.beta2"

group :development do
  # We depend on Vagrant for development, but we don't add it as a
  # gem dependency because we expect to be installed within the
  # Vagrant environment itself using `vagrant plugin`.
  gem 'coveralls', require: false
  gem 'pry'
end

