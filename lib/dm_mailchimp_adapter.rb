require 'xmlrpc/client'
require 'dm-core'
require 'pp'
require File.dirname(__FILE__) + '/xml_rpc_connector'

module MailChimpAPI
   class CreateError < StandardError; end
   class ReadError < StandardError; end
   class DeleteError < StandardError; end
   class UpdateError < StandardError; end
end

module DataMapper
  module Adapters
    class MailchimpAdapter < AbstractAdapter
      CHIMP_URL = "http://api.mailchimp.com/1.2/" 

      include XmlRpcConnector

      attr_reader :client, :authorization, :mailing_list_id


      def initialize(name, uri_or_options)
        super(name, uri_or_options)
        # @client = XMLRPC::Client.new2(CHIMP_URL)  
        @mailing_list_id = uri_or_options[:mailing_list_id]
        @api_key = uri_or_options[:api_key]
        protocol_initializer 
      end

      def create(resources)
        created = 0
        if resources.size > 1
          batch = Array.new(resources.size)
          resources.each do |resource|
            batch << resource.build_mail_merge
            created += 1
          end
          chimp_batch_subscribe(batch)
        else
           chimp_subscribe(resources.first)
           created += 1
        end
        created
      end

      def read_many(query)
        Collection.new(query) do |set|
          read(query, set, true)
        end
      end
      
      def read_one(query)
        result = read(query, query.model, false)
        # TODO - this is hacky
        if(result.is_a?(Array))
          result.first
        else
          result
        end
      end
    
      def update(attributes, query)
        updated = 0
        chimp_update(extract_query_options(query), extract_update_options(attributes))
        updated += 1
      end
      
      def delete(query)
        deleted = 0
        chimp_remove(extract_query_options(query))
        deleted += 1
      end
      
      private
      
      def result_values(result, properties, model)
        properties.map do |property|
          field_name = property.field.to_s
          if(result.key?(field_name))
            property.typecast(result[field_name])
          else
            mapping = model.mail_merge
            property.typecast(result["merges"][mapping[field_name]])
          end
        end
      end

      def read(query, set, arr = true)
        results = chimp_all_members(extract_query_options(query))
        results = results.map {|result| chimp_read_member(extract_query_options(query).merge(:email => result['email'])) }
        properties = query.fields
        results.each do |result|
          values = result_values(result, properties, query.model)
          # This is the core logic that handles the difference between all/first
          arr ? set.load(values) : (break set.load(values, query))
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
     
      def extract_update_options(attributes)
        merge_vars = {} 
        attributes.each do |prop,val|
           case prop.name
             when "email" then merge_vars.merge!("EMAIL" => val)
             when "first_name" then merge_vars.merge!("FNAME" => val)
             when "last_name" then merge_vars.merge!("LNAME" => val)
           end
        end
        merge_vars
      end
      
      def extract_query_options(query)
        options = {}
        options.merge!(:mailing_list_id => @mailing_list_id) 
        options.merge!(:status => 'subscribed')
        query.conditions.each do |condition|
          operator, property, value = condition
          case property.name
            when :mailing_list_id then options.merge!(:mailing_list_id => value) 
            when :email then options.merge!(:email => value) 
            when :status then options.merge!(:status => value) 
            when :key then options.merge!(:email => value)
          end
        end
        options
      end
        
    end  
  end
end



