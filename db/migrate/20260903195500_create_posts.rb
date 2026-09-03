class CreatePosts < ActiveRecord::Migration[8.1]
  def change
    create_table :posts do |t|
      t.references :author, null: false, foreign_key: { to_table: :users }
      t.string :title, null: false
      t.string :url
      t.text :body

      t.timestamps
    end
    add_index :posts, :created_at
    add_index :posts, [ :author_id, :created_at ]
  end
end
