
ENV["RAILS_ENV"] = "test"
require File.dirname(__FILE__) + '/../../../../config/environment'
require 'test_help'
require 'rexml/document'
require File.dirname(__FILE__) + '/../lib/tsig_api'

class ActiveSupport::TestCase
  require 'rr'
  include RR::Adapters::TestUnit
end


# dummy: lets me rename a test as xtest to prevent it from running
def xtest(*args)
  file = File.basename(caller.first)
  puts "Disabled test [#{file}]: #{args.first}"
end
