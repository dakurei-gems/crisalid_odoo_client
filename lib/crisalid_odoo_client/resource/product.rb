module CrisalidOdooClient::Resource
  class Product < Base
    TABLE_NAME = CrisalidOdooClient::Table::PRODUCT

    def schema(attributes: [])
      @client.query.table_schema(TABLE_NAME, attributes: attributes)
    end

    def search(rules: [[]], params: {})
      @client.query.search(TABLE_NAME, rules: rules, params: params)
    end

    def search_read(rules: [[]], params: {}, fields: [])
      @client.query.search_read(TABLE_NAME, rules: rules, params: params, fields: fields)
    end

    def find(ids = [], params: {}, fields: [], first: false)
      @client.query.find(TABLE_NAME, ids, params: params, fields: fields, first: first)
    end

    def where(rules: [[]], params: {}, fields: [], first: false)
      @client.query.where(TABLE_NAME, rules: rules, params: params, fields: fields, first: first)
    end

    def create(params)
      @client.query.create(TABLE_NAME, params)
    end

    def create_in_batch(headers, params)
      @client.query.create_in_batch(TABLE_NAME, headers, params)
    end

    def update(ids, params)
      @client.query.update(TABLE_NAME, ids, params)
    end

    def destroy(ids)
      @client.query.destroy(TABLE_NAME, ids)
    end
  end
end
