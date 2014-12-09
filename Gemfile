source 'https://rubygems.org'

group :development do
  gem 'coveralls', require: false
  gem 'pry'
  # My branch contains a fix for https://github.com/thoughtbot/appraisal/issues/76
  gem 'appraisal', '~> 1.0', git: 'https://github.com/maxlinc/appraisal', branch: 'gemspec_in_group'
end

group :plugins do
  gem "vagrant", git: "https://github.com/mitchellh/vagrant.git", :branch => 'master'
  gemspec
end
