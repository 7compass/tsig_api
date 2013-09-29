require 'net/http'
require 'net/https'

module TsigApi
  module RemoteActions
    
    class Response
      attr_accessor :status
      attr_accessor :body
      attr_accessor :raw_response
      
      def initialize(ret_val, resp)
        self.status = ret_val
        self.raw_response = resp
        self.body = resp.body
      end
    end
    
    class Request
      attr_accessor :headers
      attr_accessor :proxy
      attr_accessor :proxy_port
      attr_accessor :body
      attr_accessor :http_process
      attr_accessor :url

      def initialize(options={})
        default_options = {
          :body       => nil,
          :headers    => {'Content-Type' => 'application/xml', 'Accept' => 'application/xml'},
          :proxy      => nil,
          :proxy_port => nil,
          :url        => '/api/parser'
        }
        default_options.merge!(options)
        
        self.proxy      = default_options[:proxy]
        self.proxy_port = default_options[:proxy_port]
        self.headers    = default_options[:headers]
        self.body       = default_options[:body]
        self.url        = default_options[:url]

        self.http_process = Net::HTTP.new( TsigApi::TXTSIG_HOST, TsigApi::TXTSIG_PORT, self.proxy, self.proxy_port )
        
        if TsigApi::TXTSIG_PORT.to_i == 443
          self.http_process.use_ssl = true

          # We know we're under SSL, but motherfucking openssl won't 
          # stop complaining about our cert since we upgraded to 
          # higher SHA2 hashing 
          self.http_process.verify_mode = OpenSSL::SSL::VERIFY_NONE

        end
      end
      
      def send_request
        http_process.start
        resp = http_process.post(self.url, self.body, self.headers)
        ret_val = false
        case resp
        when Net::HTTPSuccess, Net::HTTPRedirection
          ret_val = true
        else
          ret_val = false
        end
        return TsigApi::RemoteActions::Response.new(ret_val, resp)
      end
    end

  end
  
end
