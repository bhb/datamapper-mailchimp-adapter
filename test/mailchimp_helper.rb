require 'rubygems'
require 'httparty'
require 'yaml'

class MailChimpHelper
  include HTTParty
  base_uri 'http://api.mailchimp.com'
  OUTPUT = 'json'
  VERSION = '/1.2/'
  format :json

  def initialize(api_key, mailing_list_id)
    @api_key = api_key
    @mailing_list_id = mailing_list_id
  end

  # listMemberInfo(string apikey, string id, string email_address)
  def list_member_info(email_address)
    self.class.get(VERSION,
                   :query => 
                     build_query('listMemberInfo',
                                 {:email_address => email_address}))
  end

  # listBatchUnsubscribe(string apikey, string id, array emails, boolean delete_member, boolean send_goodbye, boolean send_notify)
  def list_batch_unsubscribe(emails, delete_member=true, send_goodbye=false, send_notify=false)
    self.class.post(VERSION,
                    :query => build_query('listBatchUnsubscribe',
                                          {:emails => emails,
                                            :delete_member => delete_member,
                                            :send_goodbye => send_goodbye,
                                            :send_notify => send_notify}))
  end

  # listMembers(string apikey, string id, string status, string since, integer start, integer limit)
  def list_members(status = 'subscribed', since = '', start = 0, limit = 15_000)
    self.class.get(VERSION,
                   :query => build_query('listMembers',
                                         {:status => status,
                                           :since => since,
                                           :start => start,
                                           :limit => limit}))
  end
  
  # listSubscribe(string apikey, string id, string email_address, array merge_vars, string email_type, boolean double_optin, boolean update_existing, boolean replace_interests, boolean send_welcome)
  def list_subscribe(email_address, merge_vars, email_type="html", double_optin=false, update_existing=false, replace_interests=true, send_welcome = true)
    self.class.post(VERSION,
                    :query => build_query('listSubscribe',
                                          {:email_address => email_address,
                                            :merge_vars => merge_vars,
                                            :email_type => email_type,
                                            :double_optin => double_optin,
                                            :update_existing => update_existing,
                                            :replace_interests => replace_interests,
                                            :send_welcome => send_welcome}))
  end

  # listBatchSubscribe(string apikey, string id, array batch, boolean double_optin, boolean update_existing, boolean replace_interests)
  def list_batch_subscribe(batch, double_optin=false, update_existing=false, replace_interests=true)
    self.class.post(VERSION,
                    :query => build_query('listBatchSubscribe',
                                          {:batch => batch,
                                            :double_optin => double_optin,
                                            :update_existing => update_existing,
                                            :replace_interests => replace_interests}))
  end

  private 
 
  def build_query(method,params)
    {:output => OUTPUT,
      :apikey => @api_key,
      :id => @mailing_list_id, 
      :method => method }.merge(params)
  end

end




