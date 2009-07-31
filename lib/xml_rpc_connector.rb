class XmlRpcConnector
  CHIMP_URL = "http://api.mailchimp.com/1.2/" 

  def initialize(api_key,mailing_list_id)
    @client = XMLRPC::Client.new2(CHIMP_URL)  
    @api_key = api_key
    @mailing_list_id = mailing_list_id
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
  def chimp_batch_subscribe(batch, email_content_type="html", double_optin=true, update_existing=true, replace_interests=false)
    begin
      @client.call("listBatchSubscribe", @api_key, @mailing_list_id, batch, double_optin, update_existing, replace_interests)
    rescue XMLRPC::FaultException => e
      raise MailChimpAPI::CreateError, e.faultString
    end    
  end

  def chimp_update(options, merge_vars, email_content_type="html", replace_interests=false)
    begin
      @client.call("listUpdateMember", @api_key, options[:mailing_list_id], options[:email], merge_vars, email_content_type, replace_interests) 
    rescue XMLRPC::FaultException => e
      raise MailChimpAPI::UpdateError, e.faultString
    end   
  end
  
  # TODO - is there any reason this isn't the same as chimp_all_members?
  def chimp_read_member(options)
    begin
      raise MailChimpAPI::ReadError, "Email can't be nil" if (options[:email].nil?) 
      @client.call("listMemberInfo", @api_key, options[:mailing_list_id], options[:email])  
    rescue XMLRPC::FaultException => e
      raise MailChimpAPI::ReadError, e.faultString
    end  
  end
  
  def chimp_all_members(options)
    begin
      @client.call("listMembers", @api_key, options[:mailing_list_id], options[:status], "", 0, 15000)
    rescue XMLRPC::FaultException => e
      raise MailChimpAPI::ReadError, e.faultString
    end    
  end
  
  def chimp_lists
    begin
      @client.call("lists", @api_key)
    rescue XMLRPC::FaultException => e
      raise MailChimpAPI::ReadError, e.faultString
    end    
  end

  def get_mailing_list_from_resource(resource)
    unless @mailing_list_id.nil?
      mailing_list_id = @mailing_list_id
    else
      mailing_list_id = resource.mailing_list_id
    end
  end

  # TODO - put this back to defaults, but let users change settings
  #def chimp_remove(options, delete_user=false, send_goodbye=true, send_notify=true)
  def chimp_remove(options, delete_user=true, send_goodbye=false, send_notify=false)
    begin
      raise MailChimpAPI::DeleteError, "Email and Mailing List Id can't be nil" if (options[:email].nil? || options[:mailing_list_id].nil?)
      @client.call("listUnsubscribe", @api_key, options[:mailing_list_id], options[:email], delete_user, send_goodbye, send_notify) 
    rescue XMLRPC::FaultException => e
      raise MailChimpAPI::DeleteError, e.faultString
    end   
  end
  
end
