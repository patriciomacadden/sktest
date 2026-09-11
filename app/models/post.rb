class Post < ApplicationRecord
  belongs_to :author, class_name: "User"
  has_many :comments, dependent: :destroy

  validates :title, presence: true
  validate :url_must_be_absolute_http_or_https

  def editable_by?(user)
    author == user
  end

  private
    def url_must_be_absolute_http_or_https
      return if url.blank?

      uri = URI.parse(url)
      return if uri.is_a?(URI::HTTP) && uri.host.present?

      errors.add(:url, "must be an absolute HTTP or HTTPS URL")
    rescue URI::InvalidURIError
      errors.add(:url, "must be an absolute HTTP or HTTPS URL")
    end
end
