require 'securerandom'

ActiveRecord::Base.with_advisory_lock("chromotype-setting") do
  class Setting < ActiveRecord::Base
    def_druthers :roots,
      :concurrency,
      :is_northern_hemisphere,
      :exclusion_patterns,
      :geonames_username,
      :library_root,
      :magick_engine,
      :minimum_image_pixels,
      :move_dupes_to_trash,
      :move_to_library,
      :resizes,
      :reverse_face_paths,
      :secret_token,
      :split_face_names,
      :square_crop_sizes

    serialize :value

    def self.windows?
      RbConfig::CONFIG['host_os'] =~ /mswin|mingw/
    end

    # The library root holds the imported original, duplicate, and thumbnail assets.

    def self.default_library_root
      prefix = windows? ? "My " : ""
      ENV["HOME"].to_pathname + "#{prefix}Pictures" + "Chromotype"
    end

    def self.library_root
      root = ENV['CHROMOTYPE_HOME'] || get_druther(:library_root)
      root.to_pathname.ensure_directory
    end

    def self.cache_root
      (library_root + "Caches").ensure_directory
    end

    def self.thumbnail_root
      (library_root + "Thumbnails").ensure_directory
    end

    # The "roots" are directories that are scanned for assets to import.

    def self.default_roots(home = ENV["HOME"])
      home = home.to_pathname
      roots = %w{Pictures Movies Documents Public public_html}.collect do |type|
        Dir.glob((home + "*#{type}").to_s, File::FNM_CASEFOLD)
      end
      roots.flatten!
      roots.select { |r| File.directory? r }
    end

    def self.geonames_username
      get_druther(:geonames_username) || ENV['GEONAMES_USER']
    end

    # For thumbnails and screen-sized versions:
    def self.previews_root
      (library_root + "Previews").ensure_directory
    end

    def self.masters_root
      (library_root + "Masters").ensure_directory
    end

    def self.roots
      # If people edit files in the originals or duplicates roots, we should see it.
      (get_druther(:roots) + [masters_root.to_s]).uniq
    end

    def self.keys
      defaults.keys + Setting.pluck(:key)
    end

    # If set, assets found outside of the library root will be moved into originals or modified
    def self.default_move_to_library
      false
    end

    def self.default_move_dupes_to_trash
      false
    end

    def self.default_exclusion_patterns
      %w(
      caches?
      previews
      private
      resized
      resizes
      secret
      te?mp
      thumbnails?
      thumbs?
    )
    end

    def self.exclusion_regexp
      @regex ||= begin
        # OR-together all the patterns:
        /\A#{get_druther(:exclusion_patterns).join("|")}\Z/i
      end
    end

    def self.default_minimum_image_pixels
      1024 * 768 # minimum .7mp image
    end

    def self.default_resizes
      %w(
      1920x1080
      1280x720
      640x360
      320x180
      160x90
    )
    end

    # iPhoto uses 640x480 and 360x270 (?)

    # Do you want to store "Firstname Lastname",
    # or "Firstname/Lastname" for face tags?
    # (See FaceTag)
    def self.default_split_face_names
      true
    end

    # Do you want "lastname/firstname", or "firstname/lastname"?
    # (See FaceTag)
    def self.default_reverse_face_paths
      true
    end

    # Common screen resolutions:
    # 1280 x 720  (720p)
    # 1366 x 768  (11" MBA)
    # 1280 x 800  (Nexus 7)
    # 1440 x 900  (13" MBA)
    # 1920 x 1080 (1080p, 21" iMac)
    # 1920 x 1200 (17" MBP)
    # 2560 x 1440 (27" iMac)
    # 2048 x 1536 (iPad 3)
    # 2560 x 1600 (Nexus 10)
    # 2560 x 1600 (30" LCD) -- but by adding this resolution, we double the time
    # 2560 x 1700 (Google Chromebook Pixel)
    # it takes to process an image.

    def self.default_square_crop_sizes
      [320, 64]
    end

    def self.resizes
      sort_dimensions(self.get_druther(:resizes))
    end

    def self.square_crop_sizes
      get_druther(:square_crop_sizes).sort.reverse
    end

    def self.sort_dimensions(dimensions)
      dimensions.sort_by do |a|
        a.split(/[^\d]/).first(2).inject(1) { |p, i| p * i.to_i }
      end.reverse
    end

    # Used for seasons tagging. This is expensive, so we only do it once
    # and save it, rather than just setting a default.
    if get_druther(:is_northern_hemisphere).nil?
      set_druther(:is_northern_hemisphere, IpLocation.northern_hemisphere? || true)
    end

    # How much parallelism do we allow for sidekiq? Should not exceed number of CPUs.
    if self.concurrency.to_i <= 0
      self.concurrency = [Parallel.processor_count - 1, 1].max # at least 1
    end

    def self.secret_token
      get_druther(:secret_token) ||
        set_druther(:secret_token, SecureRandom.urlsafe_base64(60))
    end
  end
end
