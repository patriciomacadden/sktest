class CreatePosts < ActiveRecord::Migration[8.1]
  def change
    create_table :posts do |t|
      t.references :author, null: false, foreign_key: { to_table: :users }
      t.string :title, null: false
      t.text :url
      t.text :body
      t.integer :votes_count, null: false, default: 0

      t.timestamps
    end

    add_index :posts, [ :votes_count, :created_at ]
  end
end
