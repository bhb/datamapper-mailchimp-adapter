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

      attr_reader :client, :authorization, :mailing_list_id

      def initialize(name, uri_or_options)
        super(name, uri_or_options)
        @mailing_list_id = uri_or_options[:mailing_list_id]
        @api_key = uri_or_options[:api_key]
        @mailchimp_api = XmlRpcConnector.new(@api_key,@mailing_list_id)
      end

      def create(resources)
        created = 0
        if resources.size > 1
          batch = resources.map { |resource| resource.build_mail_merge }
          created += resources.length
          @mailchimp_api.chimp_batch_subscribe(batch)
        else
          @mailchimp_api.chimp_subscribe(resources.first)
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

      # TODO - this looks like a potential bug - shouldn't chimp_update tell how many resources were updated?
      # Or perhaps this cannot update more than one item at once?
      def update(attributes, query)
        updated = 0
        @mailchimp_ami.chimp_update(extract_query_options(query), extract_update_options(attributes))
        updated += 1
      end
      
      # TODO - this looks like a bug - shouldn't chimp_update tell how many resources were deleted?
      def delete(query)
        deleted = 0
        @mailchimp_api.chimp_remove(extract_query_options(query))
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
        results = @mailchimp_api.chimp_all_members(extract_query_options(query))
        results = results.map {|result| @mailchimp_api.chimp_read_member(extract_query_options(query).merge(:email => result['email'])) }
        properties = query.fields
        results.each do |result|
          values = result_values(result, properties, query.model)
          # This is the core logic that handles the difference between all/first
          arr ? set.load(values) : (break set.load(values, query))
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



