class SeasonTag < Tag

  def self.root_name
    "seasons"
  end

  def self.seasons_root
    named_root(DateTag.named_root)
  end

  def self.for_date(date)
    I18n.t("tags.#{self.root_name}.name")
    season_name = I18n.t("tags.seasons.#{date.season.to_s}")
    seasons_root.find_or_create_by_path season_name
  end

  def self.visit_asset(asset)
    date = asset.captured_at
    asset.add_tag(for_date(date), self)
  end

end
