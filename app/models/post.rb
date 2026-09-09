class Post < ApplicationRecord
  belongs_to :author, class_name: "User"

  has_many :comments, dependent: :destroy
  has_many :votes, as: :votable, dependent: :destroy

  validates :title, presence: true

  scope :ranked, -> { order(votes_count: :desc, created_at: :desc) }

  def editable_by?(user)
    author == user
  end

  def link_url
    uri = URI.parse(url)
    url if uri.is_a?(URI::HTTP)
  rescue URI::InvalidURIError
    nil
  end
end
