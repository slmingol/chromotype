ENV["RAILS_ENV"] ||= "test"
require File.expand_path("../../config/environment", __FILE__)
require "rails/test_help"
require "minitest/rails"

require "minitest/great_expectations"
require "minitest/autorun"
require 'minitest/reporters'
MiniTest::Reporters.use! unless ENV['CI']
require 'sidekiq/testing'

# Uncomment if you want Capybara in acceptance/integration tests
# require "minitest/rails/capybara"

# Uncomment if you want awesome colorful output
# require "minitest/pride"

# Load support files
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |ea| require ea }

DatabaseCleaner.strategy = :transaction
class MiniTest::Spec
  before :each do
    DatabaseCleaner.start
  end
  after :each do
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

require "mocha/setup"
