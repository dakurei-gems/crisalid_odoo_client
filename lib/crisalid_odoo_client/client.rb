module CrisalidOdooClient
  class Client
    require 'xmlrpc/client'

    DEFAULT_TIMEOUT = 60

    attr_reader :odoo_url
    attr_reader :odoo_db
    attr_reader :odoo_user
    attr_reader :odoo_pass

    attr_reader :timeout

    def initialize(odoo_url:, odoo_db:, odoo_user:, odoo_pass:, odoo_uid: nil, timeout: DEFAULT_TIMEOUT)
      @odoo_url, @odoo_db, @timeout = odoo_url, odoo_db, timeout

      if @uid.nil?
        @odoo_user, @odoo_pass = odoo_user, odoo_pass
        @uid = connect
      end

      if @uid != false
        @models = XMLRPC::Client.new2("#{@odoo_url}/xmlrpc/2/object", nil, @timeout).proxy
        @query ||= CrisalidOdooClient::Query.new(self)
        # Client connected
      else
        # Client not connected
      end
    end

    def uid
      @uid
    end

    def models
      @models
    end

    def query
      @query
    end

    def product
      @product ||= CrisalidOdooClient::Resource::Product.new(self)
    end

    def employee
      @employee ||= CrisalidOdooClient::Resource::Employee.new(self)
    end

    def connected?
      return (uid || false) != false
    end

    private

    def connect
      begin
        common = XMLRPC::Client.new2("#{@odoo_url}/xmlrpc/2/common", nil, @timeout)
        common.call('version')
        common.call('authenticate', @odoo_db, @odoo_user, @odoo_pass, {})
      rescue
        raise CrisalidOdooClient::Error::OdooConnectionError.new('Error on connection, check the url and the database values')
      end
    end

  end
end
