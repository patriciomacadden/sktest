class CreatePosts < ActiveRecord::Migration[8.1]
  def change
    create_table :posts do |t|
      t.string :title, null: false
      t.string :url
      t.text :body
      t.references :author, null: false, foreign_key: { to_table: :users }

      t.timestamps
    end
  end
end
