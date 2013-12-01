class DateTag < Tag

  def self.root_name
    "when"
  end

  def self.for_date(d)
   named_root.find_or_create_by_path([d.year.to_s, d.month.to_s, d.day.to_s])
  end

  def self.visit_asset(asset)
    date = asset.captured_at
    asset.add_tag(for_date(date), self)
  end
end
