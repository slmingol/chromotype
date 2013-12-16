class Date
  N_HEMISPHERE = {
    12 => :winter, 1 => :winter, 2 => :winter, 3 => :spring, 4 => :spring, 5 => :spring,
    6 => :summer, 7 => :summer, 8 => :summer, 9 => :autumn, 10 => :autumn, 11 => :autumn}

  # Returns :winter, :spring, :summer, or :autumn, using UK-based month-bound seasons.
  # See http://en.wikipedia.org/wiki/Winter
  def season
    m = self.month
    # the -1 and +1 are to handle 1-indexed rot-6.
    m = ((m - 1 + 6) % 12) + 1 unless Setting.is_northern_hemisphere
    N_HEMISPHERE[m]
  end

  def month_name
    I18n.t("date.month_names")[self.month]
  end

  def ymd
    year * 10000 + month * 100 + day
  end
end
