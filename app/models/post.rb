class Post < ApplicationRecord
  include Pagination

  belongs_to :author, class_name: "User"
  has_many :votes, dependent: :delete_all
  has_many :comments, dependent: :delete_all

  normalizes :title, with: ->(value) { value.to_s.strip }
  normalizes :url, with: ->(value) {
    value = value.to_s.strip
    next if value.blank?

    value.match?(%r{\A[a-z][a-z0-9+.-]*:}i) ? value : "https://#{value}"
  }

  validates :title, presence: true
  validate :url_is_http

  scope :newest_first, -> { order(created_at: :desc, id: :desc) }
  scope :ranked_by_votes, -> { order(votes_count: :desc).newest_first }

  private
    def url_is_http
      return if url.blank?

      uri = URI.parse(url)
      return if uri.is_a?(URI::HTTP) && uri.host.present?

      errors.add(:url, "must be a valid HTTP or HTTPS URL")
    rescue URI::InvalidURIError
      errors.add(:url, "must be a valid HTTP or HTTPS URL")
    end
end
