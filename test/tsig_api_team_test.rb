require File.join(File.dirname(__FILE__), '/test_helper')

class TsigApiTeamTest < ActiveSupport::TestCase
  
  def setup

    list_response_xml = <<-EOS
    <?xml version='1.0'?>
<txtsig_response version="1.0">
  <content type="response">
    <item type="team">
      <element name='success'>
          true
      </element>
      <element name='team_1'>
          Team One
      </element>
      <element name='team_2'>
          Team Two
      </element>
      <element name='team_3'>
          Team Three
      </element>
    </item>
  </content>
</txtsig_response>
    EOS

    create_response_xml = <<-EOS
    <?xml version='1.0'?>
    <txtsig_response version="1.0">
      <content type="response">
        <item type="team">
          <element name="success">1</element>
          <element name="team_id">15</element>
        </item>
      </content>
    </txtsig_response>
    EOS
    
    query_response_xml = <<-EOS
    <?xml version='1.0'?>
    <txtsig_response version="1.0">
      <content type="response">
        <item type="team">
          <element name="success">1</element>
          <element name="group">a</element>
          <element name="team_name">Excellent Team</element>
        </item>
      </content>
    </txtsig_response>
    EOS
    
    update_response_xml = <<-EOS
    <?xml version='1.0'?>
    <txtsig_response version="1.0">
      <content type="response">
        <item type="team">
          <element name="success">1</element>
          <element name="team_id">15</element>
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

    list_response = stub('list_response')
    list_response.body(list_response_xml)
    create_response = stub('create_response')
    create_response.body(create_response_xml)
    query_response = stub('query_response')
    query_response.body(query_response_xml)
    update_response = stub('update_response')
    update_response.body(update_response_xml)
    delete_response = stub('delete_response')
    delete_response.body(delete_response_xml)
    error_response = stub('error_response')
    error_response.body(error_xml)

    @valid_list_response = TsigApi::RemoteActions::Response.new(true, list_response)
    stub(@valid_list_response).body{list_response_xml}
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
    
    @tsig_team = TsigApi::Team.new("group a")
    
    @valid_team = {:name => "Excellent Team"}
  end
  
  test 'should_initialize_team' do
    assert_equal @tsig_team.class, TsigApi::Team
    assert_equal @tsig_team.class.remote_type, :team
  end  
  
  test 'should_build_create_xml' do
    team_hash = @valid_team.merge({:has_contacts => [1, 2]})
    request = @tsig_team.create(team_hash)
    doc = REXML::Document.new(request.body)
    assert_equal "Excellent Team", REXML::XPath.first(doc, "//param[@name='team_name']").get_text.to_s
  end

  test 'should_send_list_request_and_parse_response' do
    request = @tsig_team.list
    stub(request).send_request{@valid_list_response}
    content_type, response_hash = @tsig_team.parse_response(request.send_request)

    assert_equal 'response', content_type
    assert_equal 3, response_hash.select{|k,v| k =~ /^team_\d/}.size
    assert_equal 'Team One', response_hash['team_1']
  end

  test 'should_send_create_request_and_parse_response' do
    team_hash = @valid_team.merge({:has_contacts => [1, 2]})
    request = @tsig_team.create(team_hash)
    stub(request).send_request{@valid_create_response}
    content_type, response_hash = @tsig_team.parse_response(request.send_request)
    assert_equal content_type, "response"
    assert_equal response_hash["success"], "1"
    assert_equal response_hash["team_id"], "15"
    # now we fake an error response
    stub(request).send_request{@error_response}
    content_type, response_hash = @tsig_team.parse_response(request.send_request)
    assert_equal content_type, "error"
    assert_equal response_hash["error_code"], "10"
  end
    
  test 'should_send_query_and_parse_response' do
    request = @tsig_team.query(:team_id => 15)
    stub(request).send_request{@valid_query_response}
    content_type, response_hash = @tsig_team.parse_response(request.send_request)
    assert_equal "response", content_type
    assert_equal response_hash["success"], "1"
    assert_equal "Excellent Team", response_hash["team_name"]
  end
  
  test 'should_send_delete_and_parse_response' do
    request = @tsig_team.delete(15)
    stub(request).send_request{@valid_delete_response}
    content_type, response_hash = @tsig_team.parse_response(request.send_request)
    assert_equal "response", content_type
    assert_equal response_hash["success"], "1"
  end
  
  test 'should_send_update_request_and_parse_response' do
    request = @tsig_team.update(15, {:name => "Woo"})
    stub(request).send_request{@valid_query_response}
    content_type, response_hash = @tsig_team.parse_response(request.send_request)
    assert_equal content_type, "response"
    assert_equal response_hash["success"], "1"
  end

end
