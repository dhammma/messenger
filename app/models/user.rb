class User < ActiveRecord::Base
  has_many :chat_members
  has_many :chats, through: :chat_members

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  def chat_roles(chat)
    member = chat_members.detect do |m|
      m.chat == chat
    end
    member.nil? ? nil : member.roles
  end
end