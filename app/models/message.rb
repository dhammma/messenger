class Message < ActiveRecord::Base
  belongs_to :user
  belongs_to :chat

  before_create :set_created_time

  validates :text, presence: true

  def to_api_response
    message_info = super
    message_info[:text] = text
    message_info[:user_id] = user.id
    message_info[:chat_id] = chat.id
    message_info[:created_at] = created_at.to_i

    message_info
  end

  private
  def set_created_time
    self.created_at = Time.now
  end
end