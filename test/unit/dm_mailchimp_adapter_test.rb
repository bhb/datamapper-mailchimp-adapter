require File.dirname(__FILE__) + '/../test_helper'

DataMapper.setup(:default, {
                   :adapter => 'mailchimp',
                   :api_key => CONFIG['api_key'],
                   :mailing_list_id => CONFIG['mailing_list_id']
                 })

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
    
    test "should call listSubscribe for single subscriber" do
      XMLRPC::Client.any_instance.expects(:call).with("listSubscribe", anything, anything, 'bob@test.com', anything, anything, anything)
      Subscriber.create(:email => 'bob@test.com')
    end

    test "should call listBatchSubscriber for multiple subscribers" do
      #      XMLRPC::Client.any_instance.expects(:call).with("listBatchSubscribe", anything, anything, 'bob@test.com', anything, anything, anything)
      #      Subscriber.create([{:email => 'bob@test.com'},
      #                         {:email => 'stan@test.com'}])
    end
    
  end

  testing "#read_many" do

    #  
    #
    
  end

  testing "#read_one" do

    # test "" do
#       subscriber = {'email' => 'bob@test.com'}#   #stub_everything(email => 'bob@test.com')
#       XMLRPC::Client.any_instance.stubs(:call).returns([subscriber])
# #      XMLRPC::Client.any_instance.stubs(:call).returns([subscriber])
#       assert_equal subscriber, Subscriber.first
#     end

    test "should handle getting an Array from #read" do
      subscriber = stub_everything
      DataMapper::Adapters::MailchimpAdapter.any_instance.stubs(:read).returns([subscriber])
      assert_equal subscriber, Subscriber.first
    end

    test "should handle getting a non-Array from #read" do
      subscriber = stub_everything
      DataMapper::Adapters::MailchimpAdapter.any_instance.stubs(:read).returns(subscriber)
      assert_equal subscriber, Subscriber.first
    end
    
    test "should call listMembers" do
      XMLRPC::Client.any_instance.expects(:call).with('listMembers', anything, anything, anything, anything, anything, anything).returns([])
      Subscriber.first
    end

    test "calls #read" do
      # datamapper class expects :read with query, model, false
      # call Subscriber.first
    end

  end
  
  testing "#update" do
    # skip
  end

  testing "#delete" do
  end
  
end
