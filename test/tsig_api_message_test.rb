require File.join(File.dirname(__FILE__), '/test_helper')

class TsigApiMessageTest < ActiveSupport::TestCase
  
  def setup
    
    @tsig_message = TsigApi::Message.new("Group A")
    
    create_response_xml = <<-EOS
    <?xml version='1.0'?>
    <txtsig_response version="1.0">
      <content type="response">
        <item type="message">
          <element name='success'>1</element>
          <element name='message_id'>15</element>
        </item>
      </content>
    </txtsig_response>
    EOS
    
    query_response_xml = <<-EOS
    <?xml version='1.0'?>
    <txtsig_response version="1.0">
      <content type="response">
        <item type="message">
          <element name='success'>1</element>
          <element name='group'>a</element>
          <element name='status'>PENDING</element>
          <element name='date_sent'>2007-08-19 18:50:00</element>
          <element name='broadcast_type'>team</element>
          <element name='message'><![CDATA[sending messages is awesome]]></element>
        </item>
      </content>
    </txtsig_response>
    EOS
    
    update_response_xml = <<-EOS
    <?xml version='1.0'?>
    <txtsig_response version="1.0">
      <content type="response">
        <item type="message">
          <element name='success'>1</element>
          <element name='message_id'>15</element>
        </item>
      </content>
    </txtsig_response>
    EOS
    
    delete_response_xml = <<-EOS
    <?xml version='1.0'?>
    <txtsig_response version="1.0">
      <content type="response">
        <item type="message">
          <element name='success'>1</element>
          <element name='message_id'>15</element>
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
    net_error = stub("net_error")
    net_error.body{error_xml}
    
    @valid_create_response = TsigApi::RemoteActions::Response.new(true, create_response)
    stub(@valid_create_response).body{create_response_xml}
    @valid_query_response = TsigApi::RemoteActions::Response.new(true, query_response)
    stub(@valid_query_response).body{query_response_xml}
    @valid_update_response = TsigApi::RemoteActions::Response.new(true, update_response)
    stub(@valid_update_response).body{update_response_xml}
    @valid_delete_response = TsigApi::RemoteActions::Response.new(true, delete_response)
    stub(@valid_delete_response).body{delete_response_xml}
    @error_response = TsigApi::RemoteActions::Response.new(true, net_error)
    stub(@error_response).body{error_xml}
    
    @valid_message = {:broadcast_type => "team", :date_sent => Time.now + 3600, :send_now => false, :message => "sending messages is awesome"}
  end
  
  def test_should_initialize_message
    assert_equal @tsig_message.class, TsigApi::Message
    assert_equal @tsig_message.class.remote_type, :message
  end  
  
  def test_should_build_create_xml
    message_hash = @valid_message.merge({:has_contacts => [15], :has_teams => ["Team A"]})
    request = @tsig_message.create(message_hash)
    doc = REXML::Document.new(request.body)
    assert_equal "Team A", REXML::XPath.first(doc, "//param[@name='has_teams']/team").get_text.to_s
  end
  
  def test_should_send_create_request_and_parse_response
    message_hash = @valid_message.merge({:has_contacts => [15], :has_teams => ["Team A"]})
    request = @tsig_message.create(message_hash)
    stub(request).send_request{@valid_create_response}
    content_type, response_hash = @tsig_message.parse_response(request.send_request)
    assert_equal content_type, "response"
    assert_equal response_hash["success"], "1"
    assert_equal response_hash["message_id"], "15"
    # now we fake an error response
    stub(request).send_request{@error_response}
    content_type, response_hash = @tsig_message.parse_response(request.send_request)
    assert_equal content_type, "error"
    assert_equal response_hash["error_code"], "10"
  end
    
  def test_should_send_query_and_parse_response
    request = @tsig_message.query(:message_id => 15)
    stub(request).send_request{@valid_query_response}
    content_type, response_hash = @tsig_message.parse_response(request.send_request)
    assert_equal "response", content_type
    assert_equal response_hash["success"], "1"
    assert_equal response_hash["group"], "a"
    assert_equal "sending messages is awesome", response_hash["message"]
  end
  
  def test_should_send_delete_and_parse_response
    request = @tsig_message.delete(15)
    stub(request).send_request{@valid_delete_response}
    content_type, response_hash = @tsig_message.parse_response(request.send_request)
    assert_equal "response", content_type
    assert_equal response_hash["success"], "1"
  end
  
  def test_should_send_update_request_and_parse_response
    request = @tsig_message.update(15, :send_now => true)
    stub(request).send_request{@valid_update_response}
    content_type, response_hash = @tsig_message.parse_response(request.send_request)
    assert_equal content_type, "response"
    assert_equal response_hash["success"], "1"
    assert_equal response_hash["message_id"], "15"
  end

  test 'create should return expected params' do
    request = @tsig_message.create(
        :broadcast_type => "team",
        :send_at => '2020-01-02 03:04 PM',
        :send_now => '0',
        :message => 'This is a message',
        :has_teams => [1]
    )
    assert_match %r(<param name='group'><!\[CDATA\[Group A\]\]></param>)im, request.body
    assert_match %r(<param name='broadcast_type'>team</param>)im, request.body
    assert_match %r(<param name='send_at'>2020-01-02 03:04 PM</param>)im, request.body
    assert_match %r(<param name='send_now'>false</param>)im, request.body
    assert_match %r(<param name='message'><!\[CDATA\[This is a message\]\]></param>)im, request.body
  end

end
