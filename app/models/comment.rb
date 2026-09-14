class Comment < ApplicationRecord
  belongs_to :post, counter_cache: true
  belongs_to :author, class_name: "User"
  belongs_to :parent, class_name: "Comment", optional: true
  has_many :replies, class_name: "Comment", foreign_key: :parent_id, dependent: :destroy, inverse_of: :parent

  validates :body, presence: true
  validate :parent_must_belong_to_post
  validate :parent_must_accept_replies

  def editable_by?(user)
    !deleted? && author == user
  end

  def deletable_by?(user)
    editable_by?(user)
  end

  def edited?
    edited_at.present?
  end

  def deleted?
    deleted_at.present?
  end

  def replyable?
    !deleted?
  end

  def delete!
    update!(deleted_at: Time.current)
  end

  private
    def parent_must_belong_to_post
      return if parent.blank? || parent.post == post

      errors.add(:parent, "must belong to the same post")
    end

    def parent_must_accept_replies
      return if parent.blank? || parent.replyable?

      errors.add(:parent, "cannot accept replies")
    end
end
