require File.join(File.dirname(__FILE__), '/test_helper')

class TsigApiAuthorizeTest < ActiveSupport::TestCase

  def setup
    response_xml = <<-EOS
    <?xml version='1.0'?>
    <txtsig_response version="1.0">
      <content type="response">
        <item type="user">
          <element name='success'>true</element>
          <element name='client_id'>1234</element>
          <element name='api_password'>abcde01234abcde01234abcde01234ab</element>
        </item>
      </content>
    </txtsig_response>
    EOS
    
    error_xml = <<-EOS
    <?xml version='1.0'?>
    <txtsig_response version="1.0">
      <content type="error">
        <item  type="error_description">
          <element name="error_code">10</element>
          <element name="error_text"><![CDATA[General Fault]]></element>
        </item>
      </content>
    </txtsig_response>
    EOS
    
    net_response = stub("net_response")
    net_response.body{response_xml}
    net_error = stub("net_error")
    net_error.body{error_xml}
    
    @valid_response = TsigApi::RemoteActions::Response.new(true, net_response)
    stub(@valid_response).body{response_xml}
    @error_response = TsigApi::RemoteActions::Response.new(true, net_error)
    stub(@error_response).body{error_xml}

    TsigApi::Base.establish_connection(1234, 'joe', 'clear-text-pass')
  end
  
  def test_should_initialize
    a = TsigApi::Authorize.new
    assert_equal a.class, TsigApi::Authorize
    assert_equal a.class.remote_type, :authorize
  end
  
  def test_should_build_query_xml
    a = TsigApi::Authorize.new
    request = a.query
    assert request.body.include?('<api_username><![CDATA[joe')
  end
  
  def test_should_send_request_and_parse_response
    a = TsigApi::Authorize.new
    request = a.query
    stub(request).send_request{@valid_response}
    content_type, response_hash = a.parse_response(request.send_request)
    assert_equal content_type, "response"
    assert_equal response_hash["client_id"], '1234'
    assert_equal response_hash["api_password"], 'abcde01234abcde01234abcde01234ab'
    # now we fake an error response
    stub(request).send_request{@error_response}
    content_type, response_hash = a.parse_response(request.send_request)
    assert_equal content_type, "error"
    assert_equal response_hash["error_code"], "10"
  end
    
end
