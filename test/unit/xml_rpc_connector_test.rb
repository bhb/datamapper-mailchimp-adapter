require File.dirname(__FILE__) + '/../test_helper'

class XmlRpcConnectorTest < Test::Unit::TestCase
  
  testing "#chimp_subscribe" do
    
    test "calls 'listSubscribe' with API key" do
      client = stub_everything.responds_like(XMLRPC::Client.new2(XmlRpcConnector::CHIMP_URL))
      connector = XmlRpcConnector.new('abcdef', stub_everything, client)
      client.expects(:call).with('listSubscribe', 'abcdef', anything, anything, anything, anything, anything)
      connector.chimp_subscribe(stub_everything)
    end

    test "calls 'listSubscribe' with mailing list ID" do
      client = stub_everything.responds_like(XMLRPC::Client.new2(XmlRpcConnector::CHIMP_URL))
      connector = XmlRpcConnector.new(stub_everything,'abcxyz', client)
      client.expects(:call).with('listSubscribe', anything, 'abcxyz', anything, anything, anything, anything)
      connector.chimp_subscribe(stub_everything)
    end

    test "calls 'listSubscribe' with resource email" do
      resource = stub_everything(:email => EmailAddress1)
      client = stub_everything.responds_like(XMLRPC::Client.new2(XmlRpcConnector::CHIMP_URL))
      connector = XmlRpcConnector.new(stub_everything,stub_everything, client)
      client.expects(:call).with('listSubscribe', anything, anything, EmailAddress1, anything, anything, anything)
      connector.chimp_subscribe(resource)
    end

    test "calls 'listSubscribe' with mail_merge" do
      resource = stub_everything(:build_mail_merge => {'EMAIL' =>  EmailAddress1, "FNAME" => 'Bob', 'LNAME' => 'Smith'})
      client = stub_everything.responds_like(XMLRPC::Client.new2(XmlRpcConnector::CHIMP_URL))
      connector = XmlRpcConnector.new(stub_everything,stub_everything, client)
      client.expects(:call).with('listSubscribe', anything, anything, anything, {'EMAIL' =>  EmailAddress1, "FNAME" => 'Bob', 'LNAME' => 'Smith'} , anything, anything)
      connector.chimp_subscribe(resource)
    end

    test "by default, calls 'listSubscribe' with html content type" do
      client = stub_everything.responds_like(XMLRPC::Client.new2(XmlRpcConnector::CHIMP_URL))
      connector = XmlRpcConnector.new(stub_everything,stub_everything, client)
      client.expects(:call).with('listSubscribe', anything, anything, anything, anything, 'html', anything)
      connector.chimp_subscribe(stub_everything)
    end

    test "calls 'listSubscribe' with content type" do
      client = stub_everything.responds_like(XMLRPC::Client.new2(XmlRpcConnector::CHIMP_URL))
      connector = XmlRpcConnector.new(stub_everything,stub_everything, client)
      client.expects(:call).with('listSubscribe', anything, anything, anything, anything, 'text', anything)
      connector.chimp_subscribe(stub_everything, 'text')
    end

    test "by default, calls 'listSubscribe' with double_optin false" do
      client = stub_everything.responds_like(XMLRPC::Client.new2(XmlRpcConnector::CHIMP_URL))
      connector = XmlRpcConnector.new(stub_everything,stub_everything, client)
      client.expects(:call).with('listSubscribe', anything, anything, anything, anything, anything, false)
      connector.chimp_subscribe(stub_everything, 'text')
    end

    test "calls 'listSubscribe' with double_optin" do
      client = stub_everything.responds_like(XMLRPC::Client.new2(XmlRpcConnector::CHIMP_URL))
      connector = XmlRpcConnector.new(stub_everything,stub_everything, client)
      client.expects(:call).with('listSubscribe', anything, anything, anything, anything, anything, true)
      connector.chimp_subscribe(stub_everything, 'text', true)
    end

    test "raises MailChimpAPI::CreateError if FaultException raised" do
      error = assert_raises MailChimpAPI::CreateError do
        client = stub_everything.responds_like(XMLRPC::Client.new2(XmlRpcConnector::CHIMP_URL))
        client.stubs(:call).with('listSubscribe', anything, anything, anything, anything, anything, anything).raises(MailChimpAPI::CreateError.new('Encountered error while subscribing'))
        connector = XmlRpcConnector.new(stub_everything,stub_everything, client)
        connector.chimp_subscribe(stub_everything)
      end
      assert_equal 'Encountered error while subscribing', error.message
    end
    
  end

  testing "#chimp_update" do
    
    test "calls 'listUpdateMember' with API key" do
      client = stub_everything.responds_like(XMLRPC::Client.new2(XmlRpcConnector::CHIMP_URL))
      connector = XmlRpcConnector.new('abcdef', stub_everything, client)
      client.expects(:call).with('listUpdateMember', 'abcdef', anything, anything, anything, anything, anything)
      connector.chimp_update(stub_everything, stub_everything)
    end

    test "calls 'listUpdateMember' with mailing list ID" do
      client = stub_everything.responds_like(XMLRPC::Client.new2(XmlRpcConnector::CHIMP_URL))
      connector = XmlRpcConnector.new(stub_everything,'abcxyz', client)
      client.expects(:call).with('listUpdateMember', anything, 'abcxyz', anything, anything, anything, anything)
      connector.chimp_update({:mailing_list_id => 'abcxyz'}, stub_everything)
    end

    test "calls 'listUpdateMember' with resource email" do
      resource = stub_everything(:email => EmailAddress1)
      client = stub_everything.responds_like(XMLRPC::Client.new2(XmlRpcConnector::CHIMP_URL))
      connector = XmlRpcConnector.new(stub_everything,stub_everything, client)
      client.expects(:call).with('listUpdateMember', anything, anything, EmailAddress1, anything, anything, anything)
      connector.chimp_update({:email => EmailAddress1}, stub_everything)
    end

    test "calls 'listUpdateMember' with merge vars" do
      merge_vars = {'EMAIL' =>  EmailAddress1, "FNAME" => 'Bob', 'LNAME' => 'Smith'}
      client = stub_everything.responds_like(XMLRPC::Client.new2(XmlRpcConnector::CHIMP_URL))
      connector = XmlRpcConnector.new(stub_everything,stub_everything, client)
      client.expects(:call).with('listUpdateMember', anything, anything, anything, {'EMAIL' =>  EmailAddress1, "FNAME" => 'Bob', 'LNAME' => 'Smith'} , anything, anything)
      connector.chimp_update(stub_everything, merge_vars)
    end

    test "by default, calls 'listUpdateMember' with 'html' email content type" do
      client = stub_everything.responds_like(XMLRPC::Client.new2(XmlRpcConnector::CHIMP_URL))
      connector = XmlRpcConnector.new(stub_everything,stub_everything, client)
      client.expects(:call).with('listUpdateMember', anything, anything, anything, anything, 'html', anything)
      connector.chimp_update(stub_everything, stub_everything)
    end

    test "calls 'listUpdateMember' with given email content type" do
      client = stub_everything.responds_like(XMLRPC::Client.new2(XmlRpcConnector::CHIMP_URL))
      connector = XmlRpcConnector.new(stub_everything,stub_everything, client)
      client.expects(:call).with('listUpdateMember', anything, anything, anything, anything, 'text', anything)
      connector.chimp_update(stub_everything, stub_everything, 'text')
    end

    test "by default, calls 'listUpdateMember' with replace_interests=false" do
      client = stub_everything.responds_like(XMLRPC::Client.new2(XmlRpcConnector::CHIMP_URL))
      connector = XmlRpcConnector.new(stub_everything,stub_everything, client)
      client.expects(:call).with('listUpdateMember', anything, anything, anything, anything, anything, false)
      connector.chimp_update(stub_everything, stub_everything)
    end

    test "calls listUpdateMember' with given value for replace_interests" do
      client = stub_everything.responds_like(XMLRPC::Client.new2(XmlRpcConnector::CHIMP_URL))
      connector = XmlRpcConnector.new(stub_everything,stub_everything, client)
      client.expects(:call).with('listUpdateMember', anything, anything, anything, anything, anything, true)
      connector.chimp_update(stub_everything, stub_everything, 'text', true)
    end

    test "raises MailChimpAPI::CreateError if FaultException raised" do
      error = assert_raises MailChimpAPI::CreateError do
        client = stub_everything.responds_like(XMLRPC::Client.new2(XmlRpcConnector::CHIMP_URL))
        client.stubs(:call).with('listUpdateMember', anything, anything, anything, anything, anything, anything).raises(MailChimpAPI::CreateError.new('Encountered error while subscribing'))
        connector = XmlRpcConnector.new(stub_everything,stub_everything, client)
        connector.chimp_update(stub_everything, stub_everything)
      end
      assert_equal 'Encountered error while subscribing', error.message
    end

  end

end
