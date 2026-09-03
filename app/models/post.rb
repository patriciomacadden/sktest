class Post < ApplicationRecord
  PAGE_SIZE = 20

  belongs_to :author, class_name: "User"

  normalizes :title, with: ->(value) { value.to_s.strip }
  normalizes :url, with: ->(value) {
    value = value.to_s.strip
    next if value.blank?

    value.match?(%r{\A[a-z][a-z0-9+.-]*:}i) ? value : "https://#{value}"
  }

  validates :title, presence: true
  validate :url_is_http

  scope :newest_first, -> { order(created_at: :desc, id: :desc) }

  def self.paginated(page:, posts: all)
    page = [ page.to_i, 1 ].max
    records = posts.newest_first.offset((page - 1) * PAGE_SIZE).limit(PAGE_SIZE + 1).to_a

    [ records.first(PAGE_SIZE), page, records.length > PAGE_SIZE ]
  end

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
