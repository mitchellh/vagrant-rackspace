# Note: You may need to use bundler 1.5.2 to run `appraisal install`
appraise "vagrant-1.7" do
  group :plugins do
    gem 'bundler', '>= 1.5.2', '< 1.8.0'
    gem "vagrant", :git => 'https://github.com/mitchellh/vagrant', :tag => 'v1.7.1'
  end
end

appraise "vagrant-1.6" do
  gem 'bundler', '>= 1.5.2', '< 1.7.0'
  group :plugins do
    gem "vagrant", :git => 'https://github.com/mitchellh/vagrant', :tag => 'v1.6.5'
  end
end

appraise "vagrant-1.5" do
  gem 'bundler', '= 1.5.2'
  group :plugins do
    gem "vagrant", :git => 'https://github.com/mitchellh/vagrant', :tag => 'v1.5.4'
  end
end

# Oldest supported
appraise "vagrant-1.5.0" do
  gem 'bundler', '= 1.5.2'
  group :plugins do
    gem "vagrant", :git => 'https://github.com/mitchellh/vagrant', :tag => 'v1.5.4'
  end
end

appraise "windows-wip" do
  group :plugins do
    gem "vagrant", :git => 'https://github.com/maxlinc/vagrant', :branch => 'winrm-1.3'
  end
end

