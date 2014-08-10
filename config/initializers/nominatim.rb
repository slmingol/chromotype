ActiveSupport.migration_safe_on_load do
  if Setting.nominatim_endpoint
    Nominatim.configure do |c|
      c.endpoint = Setting.nominatim_endpoint
    end
  end
end
