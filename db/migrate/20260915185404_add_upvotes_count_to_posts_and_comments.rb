class AddUpvotesCountToPostsAndComments < ActiveRecord::Migration[8.1]
  def change
    add_column :posts, :upvotes_count, :integer, default: 0, null: false
    add_column :comments, :upvotes_count, :integer, default: 0, null: false
  end
end
