require 'tsig_api/base'

module TsigApi

  class Authorize < TsigApi::Base

    self.remote_type = :authorize

    def query
      TsigApi::RemoteActions::Request.new(:body => request_xml(:authorize, nil), :url => '/api/authorize')
    end

  end

end