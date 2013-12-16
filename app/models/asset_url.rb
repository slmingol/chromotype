class AssetUrl < ActiveRecord::Base
  belongs_to :asset
  has_many :asset_urns

  validates_associated :asset
  validates_presence_of :url
  validate :immutable_url
  before_create :normalize_url_and_sha
  after_save :update_asset_basename

  # Note that the returned asset_url will not have an asset if the entity was created.
  def self.find_or_create_by_filename(filename)
    with_filename(filename).first_or_create
  end

  def self.with_filename(filename)
    with_url(filename.to_pathname)
  end

  def self.with_url(uri)
    str = uri.to_uri.to_s
    where(url: str, url_sha: str.sha1)
  end

  def self.with_any_url(urls)
    where(url_sha: urls.map { |ea| ea.to_uri.to_s.sha1 })
  end

  def self.with_any_filename(filenames)
    with_any_url(filenames.map(&:to_pathname))
  end

  # returns a Pathname instance. Will be nil unless the uri's scheme is "file"
  def pathname
    @pathname ||= to_uri.to_pathname
  end

  def basename
    pathname.basename.to_s
  end

  def exist?
    pathname && pathname.exist?
  end

  def to_uri
    @uri ||= self.url.to_uri
  end

  private

  def normalize_url_and_sha
    self.url = to_uri.normalize.to_s
    self.url_sha = self.url.to_s.sha1
  end

  def immutable_url
    if !new_record? && changed_attributes.include?(:url)
      errors.add(:url, 'immutable')
    end
  end

  def update_asset_basename
    if asset && asset.basename.nil?
      asset.update_attribute(:basename, basename)
    end
  end
end
