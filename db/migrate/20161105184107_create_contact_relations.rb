class CreateContactRelations < ActiveRecord::Migration
  def change
    create_table :contact_relations do |t|
      t.references :user, index: true
      t.references :contact, index: true
    end

    add_index :contact_relations, [:user_id, :contact_id]
  end
end
