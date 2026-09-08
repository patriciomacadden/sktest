class CreateCommentVotes < ActiveRecord::Migration[8.1]
  def change
    add_column :comments, :votes_count, :integer, null: false, default: 0

    create_table :comment_votes do |t|
      t.references :user, null: false, foreign_key: true, index: false
      t.references :comment, null: false, foreign_key: { on_delete: :cascade }, index: false

      t.timestamps
    end

    add_index :comment_votes, [ :user_id, :comment_id ], unique: true
    add_index :comment_votes, :comment_id
  end
end
