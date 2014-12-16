appraise "latest-stable" do
  group :plugins do
    gem "vagrant", :git => 'https://github.com/mitchellh/vagrant', :branch => 'v1.7.1'
  end
end

# Oldest (current release)
appraise "oldest-current" do
  group :plugins do
    gem "vagrant", :git => 'https://github.com/mitchellh/vagrant', :branch => 'v1.7.0'
  end
end

# Latest patch (previous release)
appraise "previous-release" do
  gem 'bundler', '< 1.7.0', '>= 1.5.2'
  group :plugins do
    gem "vagrant", :git => 'https://github.com/mitchellh/vagrant', :branch => 'v1.6.5'
  end
end

# Latest patch (previous release)
appraise "oldest-supported" do
  gem 'bundler', '< 1.7.0', '>= 1.5.2'
  group :plugins do
    gem "vagrant", :git => 'https://github.com/mitchellh/vagrant', :branch => 'v1.5.0'
  end
end

appraise "windows-wip" do
  group :plugins do
    gem "vagrant", :git => 'https://github.com/maxlinc/vagrant', :branch => 'winrmssl'
  end
end

