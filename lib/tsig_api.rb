# Dynamic-tsig-api

def build_global_element(elem)
  txtsig_api_config = YAML::load_file(File.join(Rails.root, "config/tsig_api.yml"))
  rails_env = Rails.env.to_s || "development"
  return txtsig_api_config[rails_env.to_sym][elem]
end

module TsigApi

  # extracts just the text from a tsig flash message
  #
  def self.text_from_flash(str)
    matches = /\<li\>(.+)\<\/li\>/im.match(str)
    messages = []
    if matches
      messages = matches[1].split(/\<\/li\>\s*\<li\>/)
    end
    return messages
  end

end

TsigApi::TXTSIG_HOST = build_global_element(:host) unless TsigApi.const_defined?(:TXTSIG_HOST)
TsigApi::TXTSIG_PORT = build_global_element(:port) unless TsigApi.const_defined?(:TXTSIG_PORT)

require 'tsig_api/contact'
require 'tsig_api/message'
require 'tsig_api/team'
require 'tsig_api/carrier'
