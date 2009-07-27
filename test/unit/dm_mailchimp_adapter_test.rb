require File.dirname(__FILE__) + '/../test_helper'

class MailchimpAdapterTest < Test::Unit::TestCase

  testing "#initialize" do
    
    test "should raise no exceptions" do
      assert_nothing_raised do
        XMLRPC::Client.stubs(:new2)
        Subscriber.new
      end
    end

  end

  testing "#create" do
    
  end
  
end
