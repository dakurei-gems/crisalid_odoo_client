module CrisalidOdooClient
  class Client
    require 'xmlrpc/client'

    attr_reader :odoo_url
    attr_reader :odoo_db
    attr_reader :odoo_user
    attr_reader :odoo_pass

    attr_reader :models
    attr_reader :uid

    def initialize(odoo_url:, odoo_db:, odoo_user:, odoo_pass:, odoo_uid: nil)
      @odoo_url, @odoo_db = odoo_url, odoo_db

      if @uid.nil?
        @odoo_user, @odoo_pass = odoo_user, odoo_pass
        @uid = connect
      end

      if @uid != false
        @models = XMLRPC::Client.new2("#{@odoo_url}/xmlrpc/2/object").proxy
        # Client connected
      else
        # Client not connected
      end
    end

    def table_schema(table, attributes: [])
      @models.execute_kw(@odoo_db, @uid, @odoo_pass, table, 'fields_get', [], {attributes: attributes})
    end

    def search(table, rules: [[]], params: {})
      @models.execute_kw(@odoo_db, @uid, @odoo_pass, table, 'search', rules, params)
    end

    def search_read(table, rules: [[]], params: {})
      @models.execute_kw(@odoo_db, @uid, @odoo_pass, table, 'search_read', rules, params)
    end

    def find(table, ids = [], rules: [[]], params: {}, fields: [], first: false)
      params[:limit]  = 1      if first
      params[:fields] = fields if fields.size > 0

      if ids.empty?
        search_read(table, rules: rules, params: params)
      else
        @models.execute_kw(@odoo_db, @uid, @odoo_pass, table, 'read', [ids], params)
      end
    end

    def create(table, params)
      if params.is_a?(Hash) && params.size > 0
        @models.execute_kw(@odoo_db, @uid, @odoo_pass, table, 'create', [params])
      else
        raise CrisalidOdooClient::Error::OdooResourceManagerError
      end
    end

    def update(table, ids, params)
      if params.is_a?(Hash) && params.size > 0 && ids.is_a?(Array) && ids.size > 0
        @models.execute_kw(@odoo_db, @uid, @odoo_pass, table, 'write', [ids, params])
      else
        raise CrisalidOdooClient::Error::OdooResourceManagerError
      end
    end

    def destroy(table, ids)
      if ids.is_a?(Array) && ids.size > 0
        @models.execute_kw(@odoo_db, @uid, @odoo_pass, table, 'unlink', [ids])
      else
        raise CrisalidOdooClient::Error::OdooResourceManagerError
      end
    end

    def connected?
      return (@uid || false) != false
    end

    private

    def connect
      begin
        common = XMLRPC::Client.new2("#{@odoo_url}/xmlrpc/2/common")
        common.call('version')
        common.call('authenticate', @odoo_db, @odoo_user, @odoo_pass, {})
      rescue
        raise CrisalidOdooClient::Error::OdooConnectionError
      end
    end

  end
end
