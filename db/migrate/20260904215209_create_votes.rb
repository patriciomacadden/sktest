class CreateVotes < ActiveRecord::Migration[8.1]
  def change
    add_column :posts, :votes_count, :integer, null: false, default: 0

    create_table :votes do |t|
      t.references :user, null: false, foreign_key: true, index: false
      t.references :post, null: false, foreign_key: true, index: false

      t.timestamps
    end

    add_index :votes, [ :user_id, :post_id ], unique: true
    add_index :votes, :post_id
  end
end
