require 'tsig_api/base'

module TsigApi

  class Message < TsigApi::Base
    self.remote_type = :message
    
    def create(options={:broadcast_type => nil, :date_sent => nil, :send_now => nil, :message => nil, :has_contacts => nil, :has_teams => nil})
      date_sent = (options[:date_sent] || options[:send_at])
      date_sent = parse_date(date_sent) if date_sent
      sndnow = %w(1 true).include?(options[:send_now].to_s)
      
      xml = <<-EOS
      <param name='group'><![CDATA[#{group_id}]]></param>
    	<param name='broadcast_type'>#{options[:broadcast_type]}</param>
    	<param name='send_at'>#{date_sent}</param>
    	<param name='send_now'>#{sndnow}</param>
    	<param name='message'><![CDATA[#{options[:message]}]]></param>
      EOS
      
      if options[:has_contacts]
        has_contact_xml = "<param name='has_contacts'>"
        options[:has_contacts].each do |at|
          has_contact_xml += "<contact>#{at}</contact>"
        end
        has_contact_xml += "</param>"
        xml += has_contact_xml
      end
      if options[:has_teams]
        has_team_xml = "<param name='has_teams'>"
        options[:has_teams].each do |at|
          has_team_xml += "<team><![CDATA[#{at}]]></team>"
        end
        has_team_xml += "</param>"
        xml += has_team_xml
      end
      TsigApi::RemoteActions::Request.new(:body => request_xml(:create, xml))
    end
    
    def query(options={:broadcast_type => nil, :date_sent => nil, :send_now => nil, :message => nil, :sent_before => nil, :sent_after => nil, :message_id => nil, :message_by_team => nil })
      xml = "<param name='group'>#{group_id}</param>"
      if options[:message_id]
        xml += "<param name='message_id'>#{options[:message_id]}</param>"
      else
        if options[:send_now]
          sndnow = 0
          sndnow = 1 if options[:send_now]
        end
        options[:send_now] = sndnow
        options[:date_sent] = parse_date(options[:date_sent]) if options[:date_sent]
        options[:sent_after] = parse_date(options[:sent_after]) if options[:sent_after]
        options[:sent_before] = parse_date(options[:sent_before]) if options[:sent_before]
        use_options = options.reject { |o, k| o == :message }
        use_options.each do |arg, val|
          xml += "<param name='#{arg.to_s}'>#{val}</param>" if val
        end
        if options[:message]
          xml += "<param name='message'><![CDATA[#{option[:message]}]]></param>"
        end
      end
      TsigApi::RemoteActions::Request.new(:body => request_xml(:query, xml))
    end
    
    def update(message_id, options={:broadcast_type => nil, :date_sent => nil, :send_now => nil, :message => nil,  :has_contacts => nil, :has_teams => nil})
      xml = "<param name='group'>#{group_id}</param>"
      xml += "<param name='message_id'>#{message_id}</param>"
      sndnow = 0
      sndnow = 1 if options[:send_now]
      options[:send_now] = sndnow
      options[:date_sent] = parse_date(options[:date_sent]) if options[:date_sent]
      [:broadcast_type, :date_sent, :send_now].each do |arg|
        xml += "<param name='#{arg}'>#{options[arg]}</param>" if options[arg]
      end
      xml += "<param name='message'><![CDATA[#{options[:message]}]]></param>" if options[:message]
      if options[:has_contacts]
        has_contact_xml = "<param name='has_contacts'>"
        options[:has_contacts].each do |at|
          has_contact_xml += "<contact>#{at}</contact>"
        end
        has_contact_xml += "</param>"
        xml += has_contact_xml
      end
      if options[:has_teams]
        has_team_xml = "<param name='has_teams'>"
        options[:has_teams].each do |at|
          has_team_xml += "<team>#{at}</team>"
        end
        has_team_xml += "</param>"
        xml += has_team_xml
      end
      TsigApi::RemoteActions::Request.new(:body => request_xml(:update, xml))
    end
    
    def delete(message_id)
      xml = "
      <param name='group'>#{group_id}</param>
      <param name='message_id'>#{message_id}</param>
      "
      TsigApi::RemoteActions::Request.new(:body => request_xml(:delete, xml))
    end

    private
    
    def parse_date(d)
      if not d.is_a?(String)
        begin
          d = d.strftime("%m/%d/%Y %H:%M %p")
        rescue
          raise "Date for message to be sent must be a string in MM-DD-YYYY HH:MM [am/pm] or a DateTime object"
        end
      end
      d
    end
    
  end
end