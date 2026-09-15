class AddHotRankingIndexToUpvotes < ActiveRecord::Migration[8.1]
  def change
    add_index :upvotes, [ :voteable_type, :created_at, :voteable_id ]
  end
end
