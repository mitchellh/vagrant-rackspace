source 'https://rubygems.org'

group :plugins do
  gemspec
  gem "vagrant", :git => "git://github.com/mitchellh/vagrant.git", :branch => "vagrant-next"
end

gem "appraisal", "1.0.0.beta2"

group :development do
  # We depend on Vagrant for development, but we don't add it as a
  # gem dependency because we expect to be installed within the
  # Vagrant environment itself using `vagrant plugin`.
  gem 'coveralls', require: false
  gem 'pry'
end

