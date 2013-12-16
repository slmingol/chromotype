module ActiveRecord
  class Relation
    def first_or_create(attributes = nil, &block)
      first || within_transaction { create_or_first(false, attributes, &block) }
    end

    def first_or_create!(attributes = nil, &block)
      first || within_transaction { create_or_first(true, attributes, &block) }
    end

    def within_transaction
      if @klass.connection.open_transactions == 0
        @klass.connection.transaction { yield }
      else
        yield
      end
    end

    def create_or_first(bang, attributes, &block)
      @klass.connection.create_savepoint
      begin
        record = bang ? create!(attributes, &block) : create(attributes, &block)
        @klass.connection.release_savepoint
        record
      rescue ActiveRecordError => e
        @klass.connection.rollback_to_savepoint
        e.is_a?(RecordNotUnique) ? first : raise
      end
    end
  end
end
