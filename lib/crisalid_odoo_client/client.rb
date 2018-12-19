module CrisalidOdooClient
  class Client
    require 'xmlrpc/client'

    DEFAULT_TIMEOUT = 60

    attr_reader :odoo_url
    attr_reader :odoo_db
    attr_reader :odoo_user
    attr_reader :odoo_pass

    attr_reader :models
    attr_reader :uid

    attr_reader :timeout

    def initialize(odoo_url:, odoo_db:, odoo_user:, odoo_pass:, odoo_uid: nil, timeout: DEFAULT_TIMEOUT)
      @odoo_url, @odoo_db, @timeout = odoo_url, odoo_db, timeout

      if @uid.nil?
        @odoo_user, @odoo_pass = odoo_user, odoo_pass
        @uid = connect
      end

      if @uid != false
        @models = XMLRPC::Client.new2("#{@odoo_url}/xmlrpc/2/object", nil, @timeout).proxy
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

    def search_read(table, rules: [[]], params: {}, fields: [])
      params[:fields] = fields if fields.size > 0

      @models.execute_kw(@odoo_db, @uid, @odoo_pass, table, 'search_read', rules, params)
    end

    def find(table, ids = [], params: {}, fields: [], first: false)
      params[:limit]  = 1      if first
      params[:fields] = fields if fields.size > 0

      @models.execute_kw(@odoo_db, @uid, @odoo_pass, table, 'read', [ids], params)
    end

    def where(table, rules: [[]], params: {}, fields: [], first: false)
      params[:limit]  = 1      if first
      params[:fields] = fields if fields.size > 0

      search_read(table, rules: rules, params: params)
    end

    def create(table, params)
      if params.is_a?(Hash) && params.size > 0
        @models.execute_kw(@odoo_db, @uid, @odoo_pass, table, 'create', [params])
      else
        raise CrisalidOdooClient::Error::OdooResourceManagerError.new('params must be a non empty Hash')
      end
    end

    def create_in_batch(table, headers, params)
      if headers.is_a?(Array) && headers.size > 0
        if params.is_a?(Array) && params.size > 0 && params.first.is_a?(Array) && params.first.size == headers.size
          @models.execute_kw(@odoo_db, @uid, @odoo_pass, table, 'load', [headers, params])["ids"]
        else
          raise CrisalidOdooClient::Error::OdooResourceManagerError.new('params must be a non empty Array of Array who has the same size as headers')
        end
      else
        raise CrisalidOdooClient::Error::OdooResourceManagerError.new('headers must be a non empty Array')
      end
    end

    def update(table, ids, params)
      if params.is_a?(Hash) && params.size > 0 && ids.is_a?(Array) && ids.size > 0
        @models.execute_kw(@odoo_db, @uid, @odoo_pass, table, 'write', [ids, params])
      else
        raise CrisalidOdooClient::Error::OdooResourceManagerError.new('params must be a non empty Hash and ids must be a non empty Array')
      end
    end

    def destroy(table, ids)
      if ids.is_a?(Array) && ids.size > 0
        @models.execute_kw(@odoo_db, @uid, @odoo_pass, table, 'unlink', [ids])
      else
        raise CrisalidOdooClient::Error::OdooResourceManagerError.new('ids must be a non empty Array')
      end
    end

    def connected?
      return (@uid || false) != false
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
