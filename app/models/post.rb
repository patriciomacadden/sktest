class Post < ApplicationRecord
  belongs_to :author, class_name: "User"
  has_many :comments, dependent: :destroy
  has_many :upvotes, as: :voteable, dependent: :destroy

  scope :newest, -> { order(created_at: :desc) }
  scope :hot, -> {
    joins(sanitize_sql_array([ <<~SQL.squish, name, 24.hours.ago ]))
      LEFT OUTER JOIN upvotes
        ON upvotes.voteable_id = posts.id
        AND upvotes.voteable_type = ?
        AND upvotes.created_at >= ?
    SQL
      .group(:id)
      .order(Arel.sql("COUNT(upvotes.id) DESC"), created_at: :desc)
  }

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
