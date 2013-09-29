require File.join(File.dirname(__FILE__), '/test_helper')

class TsigApiCarrierTest < ActiveSupport::TestCase

  def setup
    response_xml = <<-EOS
    <?xml version='1.0'?>
    <txtsig_response version="1.0">
      <content type="response">
        <item type="carriers">
          <element name='cingular'>
              Cingular
          </element>
          <element name='att'>
              AT&amp;T
          </element>
          <element name='alltel'>
              Alltel
          </element>
          <element name='verizon'>
              Verizon
          </element>
          <element name='nextel'>
              Nextel
          </element>
          <element name='sprint'>
              Sprint
          </element>
          <element name='tmobile'>
              T-Mobile
          </element>
          <element name='boostmobile'>
              Boost Mobile
          </element>
          <element name='virginmobile'>
              Virgin Mobile
          </element>
          <element name='uscellular'>
              US Cellular
          </element>
          <element name='suncom'>
              SunCom
          </element>
          <element name='centennial'>
              Centennial Wireless
          </element>
          <element name='fido_ca'>
              Fido (Canada)
          </element>
          <element name='bellmobility_ca'>
              Bell Mobility (Canada)
          </element>
          <element name='rogers_ca'>
              Rogers (Canada)
          </element>
          <element name='virginmobile_ca'>
              Virgin Mobile (Canada)
          </element>
          <element name='telus_ca'>
              Telus (Canada)
          </element>
          <element name='cellularone'>
              Cellular One
          </element>
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

    TsigApi::Base.establish_connection(1234, 'joe', '123456789012345678901234567890ab')
  end
  
  def test_should_initialize_carrier
    c = TsigApi::Carrier.new("Group A")
    assert_equal c.class, TsigApi::Carrier
    assert_equal c.class.remote_type, :carriers
  end
  
  def test_should_build_query_xml
    c = TsigApi::Carrier.new("Group A")
    request = c.query
    assert request.body.include?('<action type="list_carriers">')
    assert request.body.include?('<client_id><![CDATA[1234]]></client_id>')
    assert request.body.include?('<api_username><![CDATA[joe]]></api_username>')
    assert request.body.include?('<api_password><![CDATA[123456789012345678901234567890ab]]></api_password>')
  end
  
  def test_should_send_request_and_parse_response
    c = TsigApi::Carrier.new("Group A")
    request = c.query
    stub(request).send_request{@valid_response}
    content_type, response_hash = c.parse_response(request.send_request)
    assert_equal content_type, "response"
    assert_equal response_hash["cellularone"], "Cellular One"
    # now we fake an error response
    stub(request).send_request{@error_response}
    content_type, response_hash = c.parse_response(request.send_request)
    assert_equal content_type, "error"
    assert_equal response_hash["error_code"], "10"
  end
    
end
