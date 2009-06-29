require 'test/unit'
require 'pending'
require 'yaml'

require File.expand_path(File.join(File.dirname(__FILE__), %w[.. lib dm_mailchimp_adapter]))

CONFIG =  YAML::load_file(File.dirname(__FILE__)+'/test_mailchimp_account.yml')

class Subscriber
  include DataMapper::Resource
  
  property :id, String, :serial => true, :key => true, :field => :_id
  property :first_name, String
  property :last_name, String
  property :email, String
  property :mailing_list_id, String
  
end

class Test::Unit::TestCase

  def self.testing(name)
    @group = name
    yield
    @group = nil
  end

  def self.test(name, &block)
    name.extend(Squish)
    test_name = @group ? "test for '#{@group}': #{name.squish}".to_sym : "test: #{name.squish}".to_sym
    defined = instance_method(test_name) rescue false
    raise "#{test_name} is already defined in #{self}" if defined
    define_method(test_name, &block)
  end

  def self.pending_test(name, &block)
    test(name) do
      puts "\nPENDING: #{name} (in #{eval('"#{__FILE__}:#{__LINE__}"', block.binding)})"
    end
  end
  
end

module Squish
  
  def squish
    dup.extend(Squish).squish!
  end
  
  # Performs a destructive squish. See String#squish.
  def squish!
    strip!
    gsub!(/\s+/, ' ')
    self
  end

end
