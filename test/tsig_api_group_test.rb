require File.join(File.dirname(__FILE__), '/test_helper')

class TsigApiGroupTest < ActiveSupport::TestCase

  def setup
    response_xml = <<-EOS
    <?xml version='1.0'?>
<txtsig_response version="1.0">
  <content type="response">
    <item type="groups">
      <element name='success'>
          true
      </element>
      <element name='group_a'>
          Group A
      </element>
      <element name='group_b'>
          Foo
      </element>
      <element name='group_c'>
          Group C
      </element>
      <element name='group_d'>
          Group D
      </element>
      <element name='group_e'>
          Group E
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
    g = TsigApi::Group.new
    assert_equal TsigApi::Group, g.class
    assert_equal :groups, g.class.remote_type
  end
  
  def test_should_build_query_xml
    g = TsigApi::Group.new
    request = g.query
    assert request.body.include?('<action type="list_groups">')
    assert request.body.include?('<client_id><![CDATA[1234]]></client_id>')
    assert request.body.include?('<api_username><![CDATA[joe]]></api_username>')
    assert request.body.include?('<api_password><![CDATA[123456789012345678901234567890ab]]></api_password>')
  end
  
  def test_should_send_request_and_parse_response
    g = TsigApi::Group.new
    request = g.query
    stub(request).send_request{@valid_response}
    content_type, response_hash = g.parse_response(request.send_request)
    assert_equal content_type, "response"
    assert_equal response_hash["group_a"], "Group A"
    assert_equal response_hash["group_b"], "Foo"

    # now we fake an error response
    stub(request).send_request{@error_response}
    content_type, response_hash = g.parse_response(request.send_request)
    assert_equal content_type, "error"
    assert_equal response_hash["error_code"], "10"
  end
    
end
