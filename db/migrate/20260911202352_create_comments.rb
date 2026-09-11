class CreateComments < ActiveRecord::Migration[8.1]
  def change
    create_table :comments do |t|
      t.references :post, null: false, foreign_key: true
      t.references :author, null: false, foreign_key: { to_table: :users }
      t.references :parent, foreign_key: { to_table: :comments }
      t.text :body, null: false
      t.datetime :deleted_at

      t.timestamps
    end

    add_index :comments, [ :post_id, :parent_id, :created_at ]
  end
end
