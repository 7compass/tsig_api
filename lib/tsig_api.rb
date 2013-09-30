
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

require 'rexml/document'
require 'tsig_api/base'
require 'tsig_api/carrier'
require 'tsig_api/contact'
require 'tsig_api/group'
require 'tsig_api/message'
require 'tsig_api/team'
