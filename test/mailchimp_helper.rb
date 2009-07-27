require 'rubygems'
require 'httparty'
require 'yaml'

class MailChimpHelper
  include HTTParty
  base_uri 'http://api.mailchimp.com'
  OUTPUT = 'json'
  format :json

  def initialize(api_key, mailing_list_id)
    @api_key = api_key
    @mailing_list_id = mailing_list_id
  end

  def member_info(email_address)
    self.class.get('/1.2/',
                   :query => 
                     build_query('listMemberInfo',
                                 {:apikey => @api_key,
                                   :id => @mailing_list_id, 
                                   :email_address => email_address}))
  end

  private 
 
  def build_query(method,params)
    {:output => OUTPUT,
      :method => method }.merge(params)
  end

end




