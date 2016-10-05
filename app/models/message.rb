class Message < ActiveRecord::Base
  belongs_to :user
  belongs_to :chat

  before_create :set_created_time

  validates :text, presence: true

  private
  def set_created_time
    self.created_at = Time.now
  end
end