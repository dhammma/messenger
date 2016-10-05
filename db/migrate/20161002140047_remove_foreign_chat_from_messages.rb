class RemoveForeignChatFromMessages < ActiveRecord::Migration
  def change
    # Remove chat foreign key from messages,
    # because chats table has descendants tables.
    # Foreign key and table inheritance features conflict with each other
    remove_foreign_key :messages, :chat
  end
end
