appraise "latest-stable" do
  group :development do
    gem "vagrant", :git => 'git://github.com/mitchellh/vagrant.git', :branch => 'v1.4.2'
  end
end

# Oldest (current release)
appraise "oldest-current" do
  group :development do
    gem "vagrant", :git => 'git://github.com/mitchellh/vagrant.git', :branch => 'v1.4.0'
  end
end

# Latest patch (previous release)
appraise "previous-release" do
  group :development do
    gem "vagrant", :git => 'git://github.com/mitchellh/vagrant.git', :branch => 'v1.3.5'
  end
end

appraise "windows-wip" do
  group :development do
    gem "vagrant", :git => 'git://github.com/maxlinc/vagrant.git', :branch => 'winrmssl'
  end
end

