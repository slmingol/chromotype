ENV['RAILS_ENV'] ||= 'test'

if ENV['CHROMOTYPE_TEST_HOME']
  TESTING_HOME = ENV['CHROMOTYPE_TEST_HOME']
else
  require 'tmpdir'
  TESTING_HOME = Dir.mktmpdir
end
ENV['CHROMOTYPE_HOME'] = TESTING_HOME

require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'

def in_dir(dir)
  cwd = Dir.pwd
  Dir.chdir(dir)
  yield
ensure
  Dir.chdir(cwd)
end

if ENV['CI']
  # We don't need to normally hit the web services to do tests—let's pre-heat the cache:
  in_dir(Setting.library_root) do
    # Rebuild by:
    # cd /var/tmp/chromotype_testing ; tar cvzf ~/code/chromotype/ci/caches.tgz Caches
    `tar xzf #{Rails.root + "ci/caches.tgz"}`
  end
end

require 'minitest/great_expectations'
require 'minitest/autorun'
# require 'minitest/reporters'
# Minitest::Reporters.use! Minitest::Reporters::SpecReporter.new

require 'sidekiq/testing'
# require "minitest/rails/capybara"

if ENV['CHROMOTYPE_TEST_HOME'].blank?
  MiniTest::Unit.after_tests do
    FileUtils.remove_entry_secure TESTING_HOME
  end
end

# Load support files
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |ea| require ea }

DatabaseCleaner.strategy = :truncation
class MiniTest::Spec
  before do
    DatabaseCleaner.start
  end
  after do
    DatabaseCleaner.clean
  end
end

def img_path(basename)
  "#{File.dirname(__FILE__)}/images/#{basename}".to_pathname
end

def with_tmp_dir(&block)
  in_dir(Dir.mktmpdir) do
    yield(Pathname.pwd)
  end
end

def asset_must_include_all_tags(asset, tags_to_visitor)
  paths = asset.reload.tags.collect { |t| t.ancestry_path.join("/") }
  paths.must_include_all tags_to_visitor.keys
  asset.asset_tags.each do |ea|
    path = ea.tag.ancestry_path.join("/")
    ea.visitor.must_equal(tags_to_visitor[path]) if tags_to_visitor.has_key? path
  end
end

require 'mocha/setup'
