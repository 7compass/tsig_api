require 'tsig_api/base'

module TsigApi
  class Team < TsigApi::Base
    self.remote_type = :team
    
    # this might be somewhat redundant to query(:all_teams => true), but
    # it seems that that will only return the ids, not id => name
    #
    def list
      xml = group_id_node
      TsigApi::RemoteActions::Request.new(:body => request_xml(:list, xml))
    end

    def create(options = {:name => nil, :add_contacts => nil})
      contact_xml = ""
      if options[:add_contacts]
      	contact_xml += "<param name='add_contacts'>"
        options[:add_contacts].each do |ac|
          contact_xml += "<contact>#{ac}</contact>"
        end
        contact_xml += "</param>"
      end
      xml = "
      #{group_id_node}
      #{param_node('team_name', options[:name])}
    	#{contact_xml}
      "
      TsigApi::RemoteActions::Request.new(:body => request_xml(:create, xml))
    end
    
    def query(options = {:name => nil, :team_id => nil, :all_teams => nil})
      xml = group_id_node
      if options[:team_id]
        xml += "<param name='team_id'>#{options[:team_id]}</param>"
      elsif options[:name]
        xml += "<param name='team_name'>#{options[:name]}</param>"
      elsif options[:all_teams] 
        xml += "<param name='all_teams'>1</param>"
      end
      TsigApi::RemoteActions::Request.new(:body => request_xml(:query, xml))
    end
    
    def update(team_id, options = {:name => nil, :add_contacts => nil, :del_contacts => nil})
      xml = group_id_node
      xml += param_node('team_id', team_id)
      xml += param_node('team_name', options[:name]) if options[:name]
      if options[:add_contacts]
        add_contact_xml = "<param name='add_contacts'>"
        options[:add_contacts].each do |ac|
          add_contact_xml += "<contact>#{ac}</contact>"
        end
        add_contact_xml += "</param>"
        xml += add_contact_xml
      end
      if options[:del_contacts]
        del_contact_xml = "<param name='del_contacts'>"
        options[:del_contacts].each do |dc|
          del_contact_xml += "<contact>#{dc}</contact>"
        end
        del_contact_xml += "</param>"
        xml += del_contact_xml
      end
      TsigApi::RemoteActions::Request.new(:body => request_xml(:update, xml))
    end
    
    def delete(options = {:team_id => nil, :name => nil})
      xml = group_id_node
      
      if options[:team_id]
        xml+= param_node('team_id', options[:team_id])
      elsif options[:name]
        xml+= "<param name='team_id'></param>#{param_node('team_name', options[:name])}"
      end
      TsigApi::RemoteActions::Request.new(:body => request_xml(:delete, xml))
    end

  end
end