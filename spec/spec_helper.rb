if ENV['COVERAGE'] != 'false'
  require 'simplecov'
  require 'coveralls'
  SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter[
    SimpleCov::Formatter::HTMLFormatter,
    Coveralls::SimpleCov::Formatter
  ]
  SimpleCov.start

  # Normally classes are lazily loaded, so any class without a test
  # is missing from the report.  This ensures they show up so we can
  # see uncovered methods.
  require 'vagrant'
  Dir["lib/**/*.rb"].each do|file|
    require_string = file.match(/lib\/(.*)\.rb/)[1]
    require require_string
  end
end

require 'fog'
