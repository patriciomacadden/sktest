class Comment < ApplicationRecord
  belongs_to :post, counter_cache: true
  belongs_to :author, class_name: "User"
  belongs_to :parent_comment, class_name: "Comment", optional: true

  has_many :replies, class_name: "Comment", foreign_key: :parent_comment_id
  has_many :votes, as: :votable, dependent: :destroy

  validates :body, presence: true, unless: :deleted?
  validate :parent_belongs_to_post

  def deleted?
    deleted_at.present?
  end

  def replyable?
    !deleted?
  end

  def editable_by?(user)
    !deleted? && author == user
  end

  def delete_by!(user)
    raise ActiveRecord::RecordNotFound unless editable_by?(user)

    update!(body: "[deleted]", deleted_at: Time.current)
  end

  private
    def parent_belongs_to_post
      return unless parent_comment && parent_comment.post_id != post_id

      errors.add(:parent_comment, "must belong to the same post")
    end
end
