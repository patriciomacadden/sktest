class Comment < ApplicationRecord
  belongs_to :post
  belongs_to :author, class_name: "User", optional: true
  belongs_to :parent, class_name: "Comment", optional: true
  has_one :deletion, class_name: "Comment::Deletion", dependent: :delete

  validates :body, presence: true
  validates :author, presence: true, on: :create
  validate :valid_parent
  validate :unchanged_identity, on: :update
  validate :not_deleted, on: :update

  scope :oldest_first, -> { order(:created_at, :id) }

  def deleted?
    deletion.present?
  end

  def editable_by?(user)
    user.present? && author_id.present? && author_id == user.id && !deleted?
  end

  # Rails' SQLite adapter begins IMMEDIATE transactions. Bypass the request
  # query cache so the first query reserves the writer before inspecting state.
  def publish
    self.class.uncached do
      transaction do
        Post.find(post_id)
        association(:parent).reset
        if parent&.deleted?
          errors.add(:base, "This comment was deleted and can no longer receive replies.")
          false
        else
          save
        end
      end
    end
  rescue ActiveRecord::StatementTimeout
    record_contention
  end

  def revise_by(user, text)
    transaction do
      reload
      if editable_by?(user)
        self.body = text
        save
      else
        self.body = text
        errors.add(:base, "This comment can no longer be edited.")
        false
      end
    end
  rescue ActiveRecord::StatementTimeout
    self.body = text
    record_contention
  end

  def delete_by(user)
    transaction do
      reload
      if editable_by?(user)
        create_deletion!
        true
      else
        errors.add(:base, "This comment can no longer be deleted.")
        false
      end
    end
  rescue ActiveRecord::StatementTimeout
    record_contention
  end

  private
    def record_contention
      errors.add(:base, "The discussion is busy. Please try again.")
      false
    end
    def valid_parent
      return unless parent_id

      if parent.nil? || parent.post_id != post_id || parent_id == id
        errors.add(:parent, "must be another comment on this post")
      elsif new_record? && parent.deleted?
        errors.add(:parent, "can no longer receive replies")
      end
    end

    def unchanged_identity
      if will_save_change_to_post_id? || will_save_change_to_parent_id? || will_save_change_to_author_id?
        errors.add(:base, "A comment's author, post, and parent cannot be changed.")
      end
    end

    def not_deleted
      errors.add(:base, "Deleted comments cannot be edited.") if deleted?
    end
end
