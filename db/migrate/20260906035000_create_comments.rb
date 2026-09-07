class CreateComments < ActiveRecord::Migration[8.1]
  def change
    create_table :comments do |t|
      t.references :post, null: false, foreign_key: { on_delete: :cascade }
      t.references :author, foreign_key: { to_table: :users, on_delete: :nullify }
      t.bigint :parent_id
      t.text :body, null: false
      t.timestamps
      t.index [ :post_id, :id ], unique: true
      t.index [ :post_id, :parent_id, :created_at, :id ], name: "index_comments_on_thread_order"
      t.check_constraint "parent_id IS NULL OR parent_id != id", name: "comments_not_own_parent"
    end

    add_foreign_key :comments, :comments, column: [ :post_id, :parent_id ],
      primary_key: [ :post_id, :id ]

    create_table :comment_deletions do |t|
      t.references :comment, null: false, index: { unique: true }, foreign_key: { on_delete: :cascade }
      t.timestamps
    end
  end
end
