class Asset < ActiveRecord::Base

  include AttrMemoizer
  attr_memoizer :pathname

  has_many :asset_urls, -> { order 'id desc' }, dependent: :destroy
  has_many :asset_urns, through: :asset_urls

  has_many :asset_tags
  has_many :tags, through: :asset_tags

  def self.with_tag(tag)
    joins(:asset_tags).merge(AssetTag.where(tag_id: tag.id))
  end

  def self.with_tag_or_descendants(tag)
    htn = Tag._ct.quoted_hierarchy_table_name
    joins(:asset_tags).
      joins("INNER JOIN #{htn} ON asset_tags.tag_id = #{htn}.descendant_id").
      where("#{htn}.ancestor_id" => tag.id)
  end

  def self.with_url(url)
    joins(:asset_urls).merge(AssetUrl.with_url(url))
  end

  def self.with_any_url(urls)
    joins(:asset_urls).merge(AssetUrl.with_any_url(urls))
  end

  def self.without(instance)
    where(["#{quoted_table_name}.#{self.class.primary_key} != ?", instance.id])
  end

  def self.with_filename(filename)
    joins(:asset_urls).merge(AssetUrl.with_filename(filename))
  end

  def self.with_any_filename(filenames)
    joins(:asset_urls).merge(AssetUrl.with_any_filename(filenames))
  end

  def self.with_urn(urn)
    joins(:asset_urls => :asset_urns).merge(AssetUrn.with_urn(urn))
  end

  def self.with_any_urn(urns)
    joins(:asset_urls => :asset_urns).merge(AssetUrn.with_any_urn(urns))
  end

  def self.deleted
    where("#{table_name}.deleted_at IS NOT NULL")
  end

  def self.not_deleted
    where(deleted_at: nil)
  end

  def pathname
    au = asset_urls.detect { |ea| ea.exist? } || asset_urls.detect { |ea| ea.pathname }
    au.pathname if au
  end

  def captured_at
    attributes[:captured_at] || pathname.ctime
  end

  def self.create_with_pathname(pathname)
    pathname = pathname.to_pathname
    create(:basename => pathname.basename.to_s).
      tap { |ea| ea.add_pathname(pathname) }
  end

  def add_pathname(pathname)
    add_url(pathname.to_pathname.to_uri)
  end

  def add_url(url)
    asset_urls.with_url(url).safe_first_or_create!
  end

  def delete!
    update_attribute(:deleted_at, Time.now)
  end

  def deleted?
    !deleted_at.nil?
  end

  def exists?
    pathname && pathname.exists?
  end

  def lost?
    !lost_at.nil?
  end

  def sanity_check!
    if exists?
      self.lost_at = nil
    else
      self.lost_at ||= Time.now # <- only set if lost_at wasn't set already
    end
    save
  end

  def add_tag(tag, visitor = nil)
    asset_tag = asset_tags.where(tag: tag).first_or_initialize
    asset_tag.visitor = visitor.to_s if visitor
    asset_tag.save
    asset_tag
  end

  def urn_siblings_in_library
    with_same_urns.select do |ea|
      ea.pathname.child_of? Setting.library_root
    end
  end

  def move_to_library
    return unless Setting.move_to_library

    # If one already is in the originals directory, it wins.
    urn_siblings_in_library.each do |ea|
      if contents_match?(ea) && Setting.move_dupes_to_trash
        Rails.logger.warn("Moving dupe file #{pathname} into the trash. It's the same as #{ea.pathname}.")
        pathname.mv_to_trash
        return
      end
    end

    move_to_masters_root
    winner.original_asset = nil
    winner.save!
    others.each do |ea|
      ea.move_to_derivatives_root
      ea.original_asset = winner
      ea.save!
    end
  end

  def move_to_masters_root
    mv_to(Setting.masters_root)
  end

  def move_to_derivatives_root
    mv_to(Setting.derivatives_root)
  end

  def move_to_trash
    pathname.mv_to_trash
  end

  def ymd_dirs
    d = captured_at
    sprintf '%04d/%02d/%02d', d.year, d.month, d.day
  end

  def mv_to(basedir)
    dest = basedir + ymd_dirs + pathname.basename
    FileUtils.mv(pathname, dest)
  end
end
