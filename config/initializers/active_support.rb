module ActiveSupport
  def self.migration_safe_on_load
    self.on_load(:active_record) do
      begin
        yield
      rescue ActiveRecord::StatementInvalid => e
        # Rails 3.0 and 3.1 have different error messages :(
        if e.message =~ /table '[\S]+' doesn't exist/i || # mysql with rails 3.0
          e.message =~ /could not find table '[\S]+'/i || # mysql with rails 3.1
          e.message =~ /relation "[\S]+" does not exist/ # postgres on rails 3.1+
        else
          # We don't know what this exception is about. Raise.
          raise e
        end
      end
    end
  end
end
