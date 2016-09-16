class CreateMessages < ActiveRecord::Migration
  def change
    create_table :messages do |t|
      t.references :user, index: true, foreign_key: true
      t.references :chat, index: true, foreign_key: true
      t.text :text
    end
  end
end
