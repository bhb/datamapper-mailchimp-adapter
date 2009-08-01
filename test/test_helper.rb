require 'test/unit'
require 'pending'
require 'yaml'
require 'ruby-debug'
require 'mocha'

require File.expand_path(File.join(File.dirname(__FILE__), %w[.. lib dm_mailchimp_adapter]))

CONFIG =  YAML::load_file(File.dirname(__FILE__)+'/test_mailchimp_account.yml')

ListName = CONFIG['list_name']
EmailAddress1 = CONFIG['email_address1']
EmailAddress2 = CONFIG['email_address2']
EmailAddress3 = CONFIG['email_address3']

class Subscriber
  include DataMapper::Resource
  
  property :id, String, :serial => true, :field => :_id
  property :first_name, String
  property :last_name, String
  property :email, String, :key => true
  property :mailing_list_id, String
  
  #callback method used by adapter to build mail merge info for MailChimp
  def build_mail_merge
    {"EMAIL" => self.email, "FNAME" => self.first_name, "LNAME" => self.last_name }
  end

  #TODO generate this automatically
  def self.mail_merge
    {"EMAIL" => self.email.name.to_s, "FNAME" => self.first_name.name.to_s, "LNAME" => self.last_name.name.to_s }.invert
  end

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

  def assert_has_contents(expected,actual)
    if expected.length != actual.length
      raise Test::Unit::AssertionFailedError, "#{expected.length} items expected, but found #{actual.length} items"
    end
    if !expected.all? {|x| actual.member?(x)}
      raise Test::Unit::AssertionFailedError, "#{expected.inspect} expected but was #{actual.inspect}"
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
