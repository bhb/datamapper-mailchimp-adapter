require File.dirname(__FILE__) + '/../test_helper'

DataMapper.setup(:default, {
                   :adapter => 'mailchimp',
                   :api_key => CONFIG['api_key'],
                   :mailing_list_id => CONFIG['mailing_list_id']
                 })

class MailchimpAdapterTest < Test::Unit::TestCase

  def delete_all_subscribers
    Subscriber.all.each do |subscriber|
      subscriber.destroy
    end
  end
  
  def mailchimp_test_construct
    # makes sure test list is empty after tests
    delete_all_subscribers
    begin
      yield if block_given?
    ensure
      delete_all_subscribers
    end
  end

  def create_subscriber(options={})
    Subscriber.create(:email => options.fetch(:email) {'john@smith.com'},
                      :first_name => options.fetch(:first_name) {'John'},
                      :last_name => options.fetch(:last_name) {'Smith'})
  end

  test "should retrieve all subscribers from a list" do
    mailchimp_test_construct do
      john = create_subscriber(:email => 'john@doe.com')
      jane = create_subscriber(:email => 'jane@doe.com')
      assert_has_contents [jane,john], Subscriber.all
    end
  end

  test "should be able to add subscriber to list" do
    mailchimp_test_construct do
      subscriber = create_subscriber
      assert_equal [subscriber], Subscriber.all
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

    test "should map merge fields to object fields" do
      mailchimp_test_construct do
        create_subscriber(:email => 'tom@smith.com',
                          :first_name => 'Tom',
                          :last_name => 'Smith')
        subscribers = Subscriber.all
        subscribers.inspect # this forces entire collection to load
        tom = subscribers.first
        assert_equal 'Tom', tom.first_name
        assert_equal 'Smith', tom.last_name
      end
    end
    
  end

  testing "reading subscribers (using .first)" do
    
    test "should return nil if there are no subscribers" do
      mailchimp_test_construct do
        subscriber = Subscriber.first
        assert_equal [], subscriber
      end
    end

    test "should return first subscriber with no query" do
      mailchimp_test_construct do
        create_subscriber
        subscriber = Subscriber.first
        assert_not_nil subscriber
      end
    end

    test "should return first subscriber that matches email" do
      mailchimp_test_construct do
        john = create_subscriber(:email => 'john@smith.com')
        subscriber = Subscriber.first(:email => 'john@smith.com')
        assert_not_nil john, subscriber
      end
    end

    test "should return first subscriber that matches merge tag (e.g. first name)" do
      mailchimp_test_construct do
        sam = create_subscriber(:first_name => 'Sam')
        subscriber = Subscriber.first(:first_name => 'Sam')
        assert_not_nil sam, subscriber
      end
    end

    test "should map merge fields to object fields" do
      mailchimp_test_construct do
        create_subscriber(:email => 'tom@smith.com',
                          :first_name => 'Tom',
                          :last_name => 'Smith')
        tom = Subscriber.first(:email => 'tom@smith.com')
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
