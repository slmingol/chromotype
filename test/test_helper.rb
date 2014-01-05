ENV['RAILS_ENV'] ||= 'test'

if ENV['CHROMOTYPE_TEST_HOME'].present?
  TESTING_HOME = ENV['CHROMOTYPE_TEST_HOME']
else
  require 'tmpdir'
  TESTING_HOME = Dir.mktmpdir
end
ENV['CHROMOTYPE_HOME'] = TESTING_HOME

require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'

require 'minitest/great_expectations'
require 'minitest/autorun'
require 'minitest/reporters'
MiniTest::Reporters.use! unless ENV['CI']
require 'sidekiq/testing'

# Uncomment if you want Capybara in acceptance/integration tests
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
  cwd = Dir.pwd
  Dir.mktmpdir do |dir|
    Dir.chdir(dir)
    yield(Pathname.new dir)
    Dir.chdir(cwd) # jruby needs us to cd out of the tmpdir so it can remove it
  end
ensure
  Dir.chdir(cwd)
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
