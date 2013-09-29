require 'rexml/document'
require 'tsig_api/base'

module TsigApi

  class Group < TsigApi::Base

    self.remote_type = :groups
    
    def query
      TsigApi::RemoteActions::Request.new(:body => request_xml(:list, nil))
    end
    
  end

end