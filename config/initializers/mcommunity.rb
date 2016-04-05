require 'erb'
require 'yaml'


# Yeah, there's many better ways to do this, but later.
def load_yml
  cfg_file="#{::Rails.root}/config/mcommunity.yml"

  begin
    mcommunity_erb = ERB.new(IO.read(cfg_file)).result(binding)
  rescue StandardError, SyntaxError => e
    raise("#{cfg_file} could not be parsed with ERB. \n#{e.inspect}")
  end

  begin
    mcommunity_yml = YAML::load(mcommunity_erb)
  rescue => e
    raise("#{cfg_file} was found, but could not be parsed.\n#{e.inspect}")
  end

  if mcommunity_yml.nil? || !mcommunity_yml.is_a?(Hash)
    raise("#{cfg_file} was found, but was blank or malformed.\n")
  end

  begin
    raise "The #{::Rails.env} environment settings were not found in #{cfg_file}" unless mcommunity_yml[::Rails.env]
    mcommunity_cfg = mcommunity_yml[::Rails.env].symbolize_keys
  end

  mcommunity_cfg
end


yml_cfg = load_yml
Umrdr::LdapConfig.host     = yml_cfg[:host] || 'ldap.umich.edu'
Umrdr::LdapConfig.port     = yml_cfg[:port] || 636
Umrdr::LdapConfig.port     = yml_cfg[:encryption] || 'simple_tls'
Umrdr::LdapConfig.use_ssl  = yml_cfg[:use_ssl] || true
Umrdr::LdapConfig.username = yml_cfg[:username] || "mcommunityuser"
Umrdr::LdapConfig.password = yml_cfg[:password] || "mcommunitypass"