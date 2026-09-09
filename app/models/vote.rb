class Vote < ApplicationRecord
  belongs_to :user
  belongs_to :votable, polymorphic: true, counter_cache: :votes_count

  validates :votable_type, inclusion: { in: %w[Post Comment] }
end
