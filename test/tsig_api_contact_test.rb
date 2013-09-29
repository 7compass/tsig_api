require File.join(File.dirname(__FILE__), '/test_helper')

class TsigApiContactTest < ActiveSupport::TestCase
  
  def setup
    
    @tsig_contact = TsigApi::Contact.new("Group A")
    @valid_contact = {:first_name => "John", :last_name => "Test", :cell_carrier => "verizon", :cell_number => "999-999-9999", :receive_messages => true}
        
    create_response_xml = <<-EOS
    <?xml version='1.0'?>
    <txtsig_response version="1.0">
      <content type="response">
        <item type="contact">
          <element name='success'>1</element>
          <element name='contact_id'>15</element>
        </item>
      </content>
    </txtsig_response>
    EOS
    
    query_response_xml = <<-EOS
    <?xml version='1.0'?>
    <txtsig_response version="1.0">
      <content type="response">
        <item type="contact">
          <element name='success'>1</element>
          <element name='contacts'>
              <contact_id>15</contact_id>
          </element>
        </item>
      </content>
    </txtsig_response>
    EOS
    
    update_response_xml = <<-EOS
    <?xml version='1.0'?>
    <txtsig_response version="1.0">
      <content type="response">
        <item type="contact">
          <element name='success'>1</element>
          <element name='contact_id'>15</element>
        </item>
      </content>
    </txtsig_response>
    EOS
    
    delete_response_xml = <<-EOS
    <?xml version='1.0'?>
    <txtsig_response version="1.0">
      <content type="response">
        <item type="contact">
          <element name='success'>1</element>
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
    
    create_response = stub("create_response")
    create_response.body{create_response_xml}
    query_response = stub("query_response")
    query_response.body{query_response_xml}
    update_response = stub("update_response")
    update_response.body{update_response_xml}
    delete_response = stub("delete_response")
    delete_response.body{delete_response_xml}
    error_response = stub("net_error")
    error_response.body{error_xml}
    
    @valid_create_response = TsigApi::RemoteActions::Response.new(true, create_response)
    stub(@valid_create_response).body{create_response_xml}
    @valid_query_response = TsigApi::RemoteActions::Response.new(true, query_response)
    stub(@valid_query_response).body{query_response_xml}
    @valid_update_response = TsigApi::RemoteActions::Response.new(true, update_response)
    stub(@valid_update_response).body{update_response_xml}
    @valid_delete_response = TsigApi::RemoteActions::Response.new(true, delete_response)
    stub(@valid_delete_response).body{delete_response_xml}
    @error_response = TsigApi::RemoteActions::Response.new(true, error_response)
    stub(@error_response).body{error_xml}
  end
  
  def test_should_initialize_contact
    assert_equal @tsig_contact.class, TsigApi::Contact
    assert_equal @tsig_contact.class.remote_type, :contact
  end
  
  def test_should_build_create_xml
    contact_hash = @valid_contact.merge({:add_teams => ['Team A', 'Team B']})
    request = @tsig_contact.create(contact_hash)
    doc = REXML::Document.new(request.body)
    assert_equal "999-999-9999", REXML::XPath.first(doc, "//param[@name='cell_number']").get_text.to_s
  end
  
  def test_should_send_create_request_and_parse_response
    contact_hash = @valid_contact.merge({:add_teams => ['Team A', 'Team B']})
    request = @tsig_contact.create(contact_hash)
    stub(request).send_request{@valid_create_response}
    content_type, response_hash = @tsig_contact.parse_response(request.send_request)
    assert_equal content_type, "response"
    assert_equal response_hash["success"], "1"
    assert_equal response_hash["contact_id"], "15"
    # now we fake an error response
    stub(request).send_request{@error_response}
    content_type, response_hash = @tsig_contact.parse_response(request.send_request)
    assert_equal content_type, "error"
    assert_equal response_hash["error_code"], "10"
  end
    
  def test_should_send_query_and_parse_response
    request = @tsig_contact.query(:first_name => "John", :last_name => "Test")
    stub(request).send_request{@valid_query_response}
    content_type, response_hash = @tsig_contact.parse_response(request.send_request)
    assert_equal "response", content_type
    assert_equal response_hash["success"], "1"
    assert_equal response_hash["contacts"], ["15"]
  end
  
  def test_should_send_delete_and_parse_response
    request = @tsig_contact.delete(15)
    stub(request).send_request{@valid_delete_response}
    content_type, response_hash = @tsig_contact.parse_response(request.send_request)
    assert_equal "response", content_type
    assert_equal response_hash["success"], "1"
  end
  
  def test_should_send_update_request_and_parse_response
    contact_hash = @valid_contact.merge({:add_teams => ['Team A'], :del_teams => ['Team B']})
    request = @tsig_contact.update(15, contact_hash)
    stub(request).send_request{@valid_update_response}
    content_type, response_hash = @tsig_contact.parse_response(request.send_request)
    assert_equal content_type, "response"
    assert_equal response_hash["success"], "1"
    assert_equal response_hash["contact_id"], "15"
  end
  
end
