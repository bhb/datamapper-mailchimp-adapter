require File.dirname(__FILE__) + '/../test_helper'

DataMapper.setup(:default, {
                   :adapter => 'mailchimp',
                   :api_key => CONFIG['api_key'],
                   :mailing_list_id => CONFIG['mailing_list_id']
                 })

class MailchimpAdapterTest < Test::Unit::TestCase
  include DataMapper::Adapters
  
  def create_adapter(options={})
    MailchimpAdapter.new(:default,
                         {:api_key => CONFIG['api_key'],
                           :mailing_list_id => CONFIG['mailing_list_id']})
  end
  
  testing "#initialize" do
    
    test "should raise no exceptions" do
      assert_nothing_raised do
        XMLRPC::Client.stubs(:new2)
        MailchimpAdapter.new(:default,{})
      end
    end

  end

  testing "#create" do
    
    test "should call listSubscribe for single subscriber" do
      XMLRPC::Client.any_instance.expects(:call).with("listSubscribe", anything, anything, 'bob@test.com', anything, anything, anything)
      create_adapter.create([Subscriber.new(:email => 'bob@test.com')])
    end

    #test "should call listBatchSubscriber for multiple subscribers" do
    # XMLRPC::Client.any_instance.expects(:call).with("listBatchSubscribe", anything, anything, 'bob@test.com', anything, anything, anything)
    #  create_adapter.create([Subscriber.new(:email => 'bob@test.com'),
    #                         Subscriber.new(:email => 'stan@test.com')])
    # end
    
  end

  testing "#read_many" do

    test "should call listMemberInfo for each member" do
      bob = {'email' => 'bob@test.com', 'merges' => {}}
      stan = {'email' => 'stan@test.com', 'merges' => {}}
      XMLRPC::Client.any_instance.stubs(:call).with('listMembers', anything, anything, anything, anything, anything, anything).returns([bob,stan])
      XMLRPC::Client.any_instance.expects(:call).with('listMemberInfo', anything, anything, 'bob@test.com').returns(bob)
      XMLRPC::Client.any_instance.expects(:call).with('listMemberInfo', anything, anything, 'stan@test.com').returns(stan)
      #query = stub_everything(:conditions => [])
      query = DataMapper::Query.new(repository(:default),Subscriber)
      create_adapter.read_many(query).inspect
      #Subscriber.all
    end
    
  end

  testing "#read_one" do

    # test "" do
#       subscriber = {'email' => 'bob@test.com'}#   #stub_everything(email => 'bob@test.com')
#       XMLRPC::Client.any_instance.stubs(:call).returns([subscriber])
# #      XMLRPC::Client.any_instance.stubs(:call).returns([subscriber])
#       assert_equal subscriber, Subscriber.first
#     end

   #  test "should call listMembers" do
#       subscriber = {'email' => 'bob@test.com'}
#       XMLRPC::Client.any_instance.stubs(:call).returns([subscriber])
#       XMLRPC::Client.any_instance.stubs(:call).returns([subscriber])
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
      query = stub_everything(:conditions => [])
      create_adapter.read_one(query)#Subscriber.first
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
