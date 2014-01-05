module ActiveRecord
  class Relation
    def safe_first_or_create(attributes = nil, &block)
      first || within_transaction { create_or_first(false, attributes, &block) }
    end

    def safe_first_or_create!(attributes = nil, &block)
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
        # Raise if it's not a RecordNotUnique or first is empty.
        e.is_a?(RecordNotUnique) ? first || raise : raise
      end
    end
  end
end
