require File.dirname(__FILE__) + '/../test_helper'
require File.dirname(__FILE__) + '/../mailchimp_helper'

DataMapper.setup(:default, {
                   :adapter => 'mailchimp',
                   :api_key => CONFIG['api_key'],
                   :mailing_list_id => CONFIG['mailing_list_id']
                 })

class MailchimpAdapterTest < Test::Unit::TestCase

  def delete_all_subscribers(mc_helper)
    emails = mc_helper.list_members.map {|subscriber| subscriber['email']}
    mc_helper.list_batch_unsubscribe(emails)
  end
  
  def mailchimp_test_construct
    # makes sure test list is empty after tests
    mc_helper = MailChimpHelper.new(CONFIG['api_key'], CONFIG['mailing_list_id'])
    delete_all_subscribers(mc_helper)
    begin
      yield if block_given?
    ensure
      delete_all_subscribers(mc_helper)
    end
  end
  
  def batch_add_subscribers(batch)
    mc_helper = MailChimpHelper.new(CONFIG['api_key'], CONFIG['mailing_list_id'])
    formatted_batch = []
    batch.each do |subscriber|
      formatted_batch << {
        'EMAIL' => subscriber[:email]
      }
    end
    mc_helper.list_batch_subscribe(formatted_batch)
  end
  
  def create_subscriber(options={})
    Subscriber.create(:email => options.fetch(:email) {EmailAddress1},
                      :first_name => options.fetch(:first_name) {'John'},
                      :last_name => options.fetch(:last_name) {'Smith'})
  end

  testing "creating a subscriber" do
    
    test "new/save should create a subscriber" do
      pending
      #mailchimp_test_construct do
      #  subscriber = Subscriber.new(:email => EmailAddress1)
      #  assert_equal [], Subscriber.all
      #  subscriber.save
      #  assert_equal [subscriber], Subscriber.all
      #end
    end
    
    test "#create should create a subscriber" do
      mailchimp_test_construct do
        subscriber = create_subscriber
        assert_equal [subscriber], Subscriber.all
      end
    end

    test "email should be set" do
      mailchimp_test_construct do
        subscriber = create_subscriber(:email => EmailAddress2)
        assert_equal EmailAddress2, subscriber.email
      end
    end
    
    test "last name (a merge tag) should be set" do
      mailchimp_test_construct do
        subscriber = create_subscriber(:last_name => 'Jones')
        assert_equal 'Jones', subscriber.last_name
      end
    end

    test "should raise exception if subscriber already exists" do
      create_subscriber(:email => EmailAddress1)
      error = assert_raises MailChimpAPI::CreateError do
        create_subscriber(:email => EmailAddress1)
      end
      assert_equal "#{EmailAddress1} is already subscribed to list #{ListName}", error.message
    end
    
  end
  
  test "should be able to delete a subscriber" do
    mailchimp_test_construct do 
      subscriber = create_subscriber
      subscriber.destroy
      assert_equal [], Subscriber.all
    end
  end

  testing "reading subscribers (using .all)" do
    
    test "should retrieve no subscribers from an empty list" do
      mailchimp_test_construct do
        subscribers = Subscriber.all
        assert_equal [], subscribers
      end
    end

    test "should retrieve all subscribers from a list" do
      mailchimp_test_construct do
        john = create_subscriber(:email => EmailAddress1)
        jane = create_subscriber(:email => EmailAddress2)
        assert_has_contents [jane,john], Subscriber.all
      end

    end

    # This test takes a long time and is a bit unsafe because it
    # uses generated email addresses. If there is a bug, running
    # it could ask MailChimp to send out 100 confirmation emails.

    #     test "should be able to retrieve more that 100 subscribers" do
    #       mailchimp_test_construct do
    #         batch = []
    #         101.times do |x|
    #           batch << { :email => "email#{x}@test_domain#{x}.com", :first_name => "first_#{x}", :last_name => "last_#{x}"}
    #         end
    #         batch_add_subscribers(batch)
    #         assert_equal 101, Subscriber.all.length
    #       end
    #     end

    test "should map merge fields to object fields" do
      mailchimp_test_construct do
        create_subscriber(:first_name => 'Tom',
                          :last_name => 'Smith')
        subscribers = Subscriber.all
        subscribers.inspect # this forces entire collection to load
        tom = subscribers.first
        assert_equal 'Tom', tom.first_name
        assert_equal 'Smith', tom.last_name
      end
    end

    test "should return all subscribers that matches email" do
      pending
      # mailchimp_test_construct do
      #         john = create_subscriber(:email => EmailAddress1)
      #         jane = create_subscriber(:email => EmailAddress2)
      #         subscribers = Subscriber.all(:email => EmailAddress1)
      #         assert_equal 1, subscribers.length
      #       end
    end

    test "should return all subscribers that matches merge tag (e.g. first name)" do
      pending
      #mailchimp_test_construct do
      #  sam = create_subscriber(:first_name => 'Sam',
      #                          :email => EmailAddress1)
      #  tom = create_subscriber(:first_name => 'Tom',
      #                          :email => EmailAddress2)
      #  samuel = create_subscriber(:first_name => 'Sam',
      #                             :email => EmailAddress3)
      #  subscribers = Subscriber.all(:first_name => 'Sam')
      #  assert_equal 2, subscribers.length
      #end
    end
    
  end

  testing "reading subscribers (using .first)" do
    
    test "should return nil if there are no subscribers" do
      mailchimp_test_construct do
        subscriber = Subscriber.first
        assert_nil subscriber
      end
    end

    test "should return first subscriber with no query" do
      mailchimp_test_construct do
        subscriber = create_subscriber
        assert_equal subscriber, Subscriber.first
      end
    end

    test "should return first subscriber that matches email" do
      pending
      #mailchimp_test_construct do
      #  jane = create_subscriber(:email => EmailAddress1)
      #  john = create_subscriber(:email => EmailAddress2)
      #  subscriber = Subscriber.first(:email => EmailAddress2)
      #  assert_equal john, subscriber
      #end
    end

    test "should return first subscriber that matches merge tag (e.g. first name)" do
      pending
      #mailchimp_test_construct do
      #  tom = create_subscriber(:first_name => 'Tom', :email => EmailAddress1)
      #  sam = create_subscriber(:first_name => 'Sam', :email => EmailAddress2)
      #  subscriber = Subscriber.first(:first_name => 'Sam')
      #  assert_equal sam, subscriber
      #end
    end

    test "should map merge fields to object fields" do
      mailchimp_test_construct do
        create_subscriber(:email => EmailAddress1,
                          :first_name => 'Tom',
                          :last_name => 'Smith')
        tom = Subscriber.first(:email => EmailAddress1)
        assert_equal 'Tom', tom.first_name
        assert_equal 'Smith', tom.last_name
      end
    end

    test "should be able to lazily load all, then load first" do
      mailchimp_test_construct do
        subscriber = create_subscriber
        assert_equal subscriber, Subscriber.all.first
      end
    end
    
  end
  
end
