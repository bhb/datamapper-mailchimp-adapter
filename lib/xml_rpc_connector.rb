module XmlRpcConnector

  def protocol_initializer
    @client = XMLRPC::Client.new2(DataMapper::Adapters::MailchimpAdapter::CHIMP_URL)  
  end
  
  # TODO change these defaults back
  #def chimp_subscribe(resource, email_content_type="html", double_optin=true)
  def chimp_subscribe(resource, email_content_type="html", double_optin=false)
    begin
      @client.call("listSubscribe", @api_key, get_mailing_list_from_resource(resource), resource.email, resource.build_mail_merge(), email_content_type, double_optin)
    rescue XMLRPC::FaultException => e
      raise MailChimpAPI::CreateError, e.faultString
    end    
  end
  
  # TODO - this doesn't seem to match the API at all!
  def chimp_batch_subscribe(resource, email_content_type="html", double_optin=true, update_existing=true, replace_interests=false)
    begin
      @client.call("listBatchSubscribe", @api_key, get_mailing_list_from_resource(resource), resource.email, double_optin, update_existing, replace_interests)
    rescue XMLRPC::FaultException => e
      raise MailChimpAPI::CreateError, e.faultString
    end    
  end


  

end
