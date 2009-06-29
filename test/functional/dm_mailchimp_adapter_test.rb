require File.dirname(__FILE__) + '/../test_helper'

DataMapper.setup(:default, {
  :adapter => 'mailchimp',
  :username => CONFIG[:username],
  :password => CONFIG[:password],
  :mailing_list_id => CONFIG[:mailing_list_id]
})

class MailchimpAdapterTest < Test::Unit:TestCase
  
  test "should retrieve no members from an empty list" do
    members = Subscriber.all
    assert_equal [], members
  end

  test "should retrieve all members from a list" do
    
  end

end
