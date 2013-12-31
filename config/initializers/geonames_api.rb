ActiveSupport.migration_safe_on_load do
  if Setting.geonames_username
    GeoNamesAPI.username = Setting.geonames_username
  end
end
