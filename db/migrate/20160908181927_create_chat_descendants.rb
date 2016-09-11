class CreateChatDescendants < ActiveRecord::Migration
  include Database::Postgres::Migrations::TableInheritance

  def change
    create_inherit_table PrivateChat, Chat

    create_inherit_table GroupChat, Chat do |t|
      t.boolean :everyone_is_admin
    end
  end
end
