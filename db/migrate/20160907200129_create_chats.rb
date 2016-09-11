class CreateChats < ActiveRecord::Migration
  def change
    create_table :chats do |t|
      t.string :title
      t.string :type
    end
  end
end
