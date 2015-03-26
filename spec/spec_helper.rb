require 'rubygems'
require 'bundler/setup'

require 'combustion'

Combustion.initialize! :action_controller

require 'rspec/rails'
require 'serial_spec'
require 'inheritable_accessors'
require 'mongoid'
require 'database_cleaner'

$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'matterhorn'

Mongoid.load!("spec/internal/config/mongoid.yml", :test)

$LOAD_PATH.unshift File.expand_path('../../spec/support', __FILE__)

require "api_spec"
require "blueprints"
require "class_builder"
require "url_test_helpers"
require "fake_auth"

=begin

{key: BSON::ObjectId.new}.to_json
or 
[{key: BSON::ObjectId.new}.to_json]
Result in:

ArgumentError: wrong number of arguments (1 for 0)
from /Users/hbeaver/.rbenv/versions/2.1.0/lib/ruby/gems/2.1.0/gems/bson-2.3.0/lib/bson/object_id.rb:185:in `to_s'

but doing this patch works fine:

module BSON
  class ObjectId
    def as_json(opts=nil)
      to_s
    end
    alias :to_json :as_json
 end
end

=end

module BSON
  class ObjectId
    def as_json(opts=nil)
      to_s
    end
    alias :to_json :as_json
  end
end

RSpec.configure do |config|
  config.include ApiSpec, :type => :api

  config.define_derived_metadata(:file_path => %r{/spec/resources_api/}) do |metadata|
    metadata[:type] = :api
  end

  config.before(:each) do
    DatabaseCleaner.clean
  end

  config.after(:suite) do
    DatabaseCleaner.clean
  end
end
