require 'tsig_api/remote_actions'

module TsigApi

  class Base
    
    class << self
      attr_accessor :remote_type

      def establish_connection(clientid, username, password)
        @TXTSIG_CLIENT_ID = clientid
        @TXTSIG_API_USERNAME = username
        @TXTSIG_API_PASSWORD = password

        TsigApi.send(:const_set, "TXTSIG_HOST", build_global_element(:host)) unless TsigApi.const_defined?(:TXTSIG_HOST)
        TsigApi.send(:const_set, "TXTSIG_PORT", build_global_element(:port)) unless TsigApi.const_defined?(:TXTSIG_PORT)
      end

    end
    
    attr_accessor :group_id
    
    def initialize(group_id=nil)
      self.group_id = group_id
    end

    def list
      raise 'Abstract, subclass'
    end

    def create
      raise "Abstract, subclass"
    end
    
    def query
      raise "Abstract, subclass"
    end
    
    def update
      raise "Abstract, subclass"
    end
    
    def destroy
      raise "Abstract, subclass"
    end
    
    def parse_response(response)
      begin
        doc = REXML::Document.new(response.body)
      rescue
        return nil
      end
      content_type = doc.root.elements[1].attributes["type"]
      response_hash = {}
      doc.root.elements[1].elements[1].elements.each do |e|
        if e.attributes["name"] == self.class.remote_type.to_s.pluralize
          response_hash[e.attributes["name"]] = e.elements.collect do |ne| 
            if ne.cdatas.empty?
              ne.get_text.to_s.gsub(/^\s+/, "").gsub(/\s+$/, "") 
            else
              ne.cdatas[0].to_s.gsub(/^\s+/, "").gsub(/\s+$/, "")
            end 
          end
        else
          if e.cdatas.empty?
            response_hash[e.attributes["name"]] = e.get_text.to_s.gsub(/^\s+/, "").gsub(/\s+$/, "")
          else
            response_hash[e.attributes["name"]] = e.cdatas[0].to_s.gsub(/^\s+/, "").gsub(/\s+$/, "")
          end
        end
      end
      return [content_type, response_hash]
    end
    
    protected
        
    def credentials_xml
      xml = <<-EOS
        <credentials>
            <api_username><![CDATA[#{TsigApi::Base.instance_variable_get('@TXTSIG_API_USERNAME')}]]></api_username>
    	      <api_password><![CDATA[#{TsigApi::Base.instance_variable_get('@TXTSIG_API_PASSWORD')}]]></api_password>
    		    <client_id><![CDATA[#{TsigApi::Base.instance_variable_get('@TXTSIG_CLIENT_ID')}]]></client_id>
        </credentials>      
      EOS
    end
    
    def group_id_node
      param_node('group', group_id)
    end

    def param_node(name, value)
      %Q{<param name="#{name}"><![CDATA[#{value}]]></param>}
    end

    def request_xml(action, body)
      xml = <<-EOS
      <?xml version='1.0'?>
      <txtsig_request version='1.0'>
          #{credentials_xml}
          <action type="#{action.to_s.downcase}_#{self.class.remote_type}">
          #{body}
          </action>
      </txtsig_request>
      EOS
    end

  end
end