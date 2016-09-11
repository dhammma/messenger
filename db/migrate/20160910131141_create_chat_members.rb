class CreateChatMembers < ActiveRecord::Migration
  def change
    create_table :chat_members do |t|
      t.references :user, index: true
      t.references :chat, index: true
      t.integer :roles_mask
    end
  end
end
