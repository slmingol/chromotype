class Findler::Filters
  def self.exif_only(children)
    child_dirs = children.select { |ea| ea.directory? }
    child_files = children.select { |ea| ea.file? }
    files_with_exif = ExifMixin.exif_results(*child_files).keys
    files_with_exif + child_dirs
  end

  def self.with_minimum_resolution(children)
    child_dirs = children.select { |ea| ea.directory? }
    child_files = children.select { |ea| ea.file? }
    big_enough = ExifMixin.exif_results(*child_files).collect do |filename, exif|
      pixels = (e[:image_width].to_i * e[:image_height].to_i)
      return filename if pixels >= exif[:minimum_image_pixels]
    end
    big_enough + child_dirs
  end

  def self.skip_exclusion_patterns(children)
    children.select do |ea|
      !Settings.exclusion_patterns.include?(ea.basename.to_s.downcase)
    end
  end
end