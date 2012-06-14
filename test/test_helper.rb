ENV["RAILS_ENV"] = "test"

require 'pathname'

if RUBY_VERSION >= '1.9'
  require 'simplecov'
  SimpleCov.start do
    if artifacts_dir = ENV['CC_BUILD_ARTIFACTS']
      coverage_dir Pathname.new(artifacts_dir).relative_path_from(Pathname.new(SimpleCov.root)).to_s
    end
    add_filter '/test/'
    add_filter 'vendor'
  end

  SimpleCov.at_exit do
    SimpleCov.result.format!
    if result = SimpleCov.result
      File.open(File.join(SimpleCov.coverage_path, 'coverage_percent.txt'), 'w') { |f| f << result.covered_percent.to_s }
    end
  end
end

require File.expand_path('../support/irb_debugger', __FILE__)

require 'rubygems'
require 'bundler/setup'
Bundler.require(:default)
require 'test/unit'


require 'maybee'

ActiveRecord::Base.mass_assignment_sanitizer = :strict
ActiveRecord::Base.establish_connection(:adapter => 'sqlite3', :database => ':memory:')

require File.expand_path('../schema', __FILE__)
require File.expand_path('../support/custom_assertions', __FILE__)

require File.expand_path('../models/make', __FILE__)
require File.expand_path('../models/driver', __FILE__)
require File.expand_path('../models/workshop', __FILE__)
require File.expand_path('../models/car', __FILE__)
require File.expand_path('../models/exclusive_car', __FILE__)

#I18n.load_path += Pathname.glob(Pathname.new(__FILE__).dirname.join('locales').join('*.yml'))
#I18n.reload!

class ActiveSupport::TestCase
  include CustomAssertions
end
