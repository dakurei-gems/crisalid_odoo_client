module CrisalidOdooClient
  class Query

    def initialize(client)
      @models = client.models
      @odoo_db = client.odoo_db
      @uid = client.uid
      @odoo_pass = client.odoo_pass
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

  end
end
