require 'tsig_api/base'
require 'rexml/document'

module TsigApi
  class Contact < TsigApi::Base
    self.remote_type = :contact

    def create(options={:first_name => nil, :last_name => nil, :cell_carrier => nil, :cell_number => nil, :receive_messages => nil, :add_teams => nil})
      team_xml = ""
      if options[:add_teams]
      	team_xml += "<param name='add_teams'>"
        options[:add_teams].each do |at|
          team_xml += "<team>#{at}</team>"
        end
        team_xml += "</param>"
      end
      remsg = 0
      remsg = 1 if options[:receive_messages]
      xml = "
      <param name='group'>#{group_id}</param>
    	<param name='first_name'>#{options[:first_name]}</param>
    	<param name='last_name'>#{options[:last_name]}</param>
    	<param name='cell_number'>#{options[:cell_number]}</param>
    	<param name='cell_carrier'>#{options[:cell_carrier]}</param>
    	<param name='receive_messages'>#{remsg}</param>
    	#{team_xml}
      "
      TsigApi::RemoteActions::Request.new(:body => request_xml(:create, xml))
    end
    
    def query(options={:first_name => nil, :last_name => nil, :cell_carrier => nil, :cell_number => nil, :contact_id => nil})
      xml = "<param name='group'>#{group_id}</param>"
      if options[:contact_id]
        xml += "<param name='contact_id'>#{options[:contact_id]}</param>"
      else
        use_options = options.reject { |o, k| o == :contact_id }
        use_options.each do |arg, val|
          xml += "<param name='#{arg.to_s}'>#{val}</param>" if val
        end
      end
      TsigApi::RemoteActions::Request.new(:body => request_xml(:query, xml))
    end
    
    def update(contact_id, options = {:first_name => nil, :last_name => nil, :cell_carrier => nil, :cell_number => nil, :receive_messages => nil, :add_teams => nil, :del_teams => nil})
      xml = "<param name='group'>#{group_id}</param>"
      xml += "<param name='contact_id'>#{contact_id}</param>"
      use_options = options.reject { |o, v| [:add_teams, :del_teams].include?(o) }
      use_options.each do |arg, val|
        xml += "<param name='#{arg.to_s}'>#{val}</param>" if val
      end
      if options[:add_teams]
        add_team_xml = "<param name='add_teams'>"
        options[:add_teams].each do |at|
          add_team_xml += "<team>#{at}</team>"
        end
        add_team_xml += "</param>"
        xml += add_team_xml
      end
      if options[:del_teams]
        del_team_xml = "<param name='del_teams'>"
        options[:del_teams].each do |at|
          del_team_xml += "<team>#{at}</team>"
        end
        del_team_xml += "</param>"
        xml += del_team_xml
      end
      TsigApi::RemoteActions::Request.new(:body => request_xml(:update, xml))
    end
    
    def delete(contact_id)
      xml = <<-EOS
      <param name='group'>#{group_id}</param>
      <param name='contact_id'>#{contact_id}</param>
      EOS
      
      TsigApi::RemoteActions::Request.new(:body => request_xml(:delete, xml))
    end
    
  end
end