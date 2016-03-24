module Umrdr

  require 'rubygems'
  require 'net/ldap'

  ENV['LDAPTLS_CACERT'] = '../../../config/incommon_server_ca_cert.crt';

  class DepositsOkayService
    attr_accessor :ldap, :operation_result, :op_code, :deposits_okay, :uname

    HOST = 'ldap.umich.edu'
    PORT = 636
    ENCRYPTION = :simple_tls
    USERNAME =  'mcommunityuser'
    PASSWORD = 'mcommunitypass'
    AUTH = {:method => :simple, :username => USERNAME, :password => PASSWORD}

    def self.deposits_okay_for(uname)
      Umrdr::DepositsOkayService.new(uname).run
    end

    def initialize(uname)
      @uniqname = uname
    end

    # Errors returned from ldap.open in run method can include
    # "getaddrinfo: nodename nor servname provided, or not known" when HOST is wrong
    # "Operation timed out - user specified timeout" when PORT is wrong
    # "undefined method `umichinstroles' for #<Net::LDAP::Entry:OBJECT-NUMBER>" when  USERNAME is wrong
    # "undefined method `umichinstroles' for #<Net::LDAP::Entry:OBJECT-NUMBER>" when  PASSWORD is wrong
    # "Error: Invalid binding information" when the AUTH is wrong

    def run
      begin
        @ldap = Net::LDAP.open(:host => HOST, :port => PORT, :encryption => ENCRYPTION, :auth => AUTH) do |ldap|
          # set up search
          filter = Net::LDAP::Filter.eq('objectclass', '*')
          treebase = "uid=#{@uniqname},ou=People,dc=umich,dc=edu"

          @deposits_okay= false
          ldap.search( :base => treebase, :filter => filter ) do |entry|

            entry.umichinstroles.each do |value|
              @deposits_okay = true  if (value.downcase.include? "faculty") || (value.downcase.include? "regularstaff")
            end
          end
          
        end

      rescue Exception, StandardError, Net::LDAP::ConnectionError, Net::LDAP::Error, SocketError, SystemCallError, OpenSSL::SSL::SSLError => e
        raise "LDAP PROBLEM - Error: #{e}"
      end

      return (@deposits_okay == true)

    end

  end
end