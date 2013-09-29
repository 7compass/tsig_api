require 'rexml/document'
require 'tsig_api/base'

module TsigApi

  class Carrier < TsigApi::Base

    self.remote_type = :carriers
    
    def query
      TsigApi::RemoteActions::Request.new(:body => request_xml(:list, "<param name='group'>#{group_id}</param>"))
    end
    
  end

end