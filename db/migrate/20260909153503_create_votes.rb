class CreateVotes < ActiveRecord::Migration[8.1]
  def change
    create_table :votes do |t|
      t.references :user, null: false, foreign_key: true
      t.references :votable, null: false, polymorphic: true

      t.timestamps
    end

    add_index :votes, [ :user_id, :votable_type, :votable_id ], unique: true
  end
end
