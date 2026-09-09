class CreateComments < ActiveRecord::Migration[8.1]
  def change
    create_table :comments do |t|
      t.references :post, null: false, foreign_key: true
      t.references :author, null: false, foreign_key: { to_table: :users }
      t.references :parent_comment, foreign_key: { to_table: :comments, on_delete: :nullify }
      t.text :body, null: false
      t.datetime :deleted_at
      t.integer :votes_count, null: false, default: 0

      t.timestamps
    end

    add_index :comments, [ :post_id, :parent_comment_id, :created_at ]
  end
end
