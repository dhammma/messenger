class Message < ActiveRecord::Base
  belongs_to :user
  belongs_to :chat

  validates :text, presence: true
end