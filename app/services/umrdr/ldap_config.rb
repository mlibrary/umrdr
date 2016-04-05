module Umrdr
  class LdapConfig

    # class variables from config set in /config/initializers/mcommunity.rb

    # getters
    def self.host
      @@host
    end

    def self.port
      @@port
    end

    def self.encryption
      @@encryption
    end

    def self.use_ssl
      @@use_ssl
    end

    def self.username
      @@username
    end

    def self.password
      @@password
    end

    def self.auth
      @@auth
    end

    # setters
    def self.host=(value)
      @@host = value
    end

    def self.port=(value)
      @@port = value
    end

    def self.encryption=(value)
      @@encryption = value
    end

    def self.use_ssl=(value)
      @@use_ssl = value
    end

    def self.username=(value)
      @@username = value
    end

    def self.password=(value)
      @@password = value
    end

    def self.auth=(value)
      @@auth = value     # { method: :simple, username: @@username, password: @@password }
    end

  end
end


