class User < ActiveRecord::Base
  # Include default devise modules.. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  include DeviseTokenAuth::Concerns::User

  has_many :chat_members
  has_many :chats, through: :chat_members
  has_many :messages

  def chat_roles(chat)
    member = chat_members.detect do |m|
      m.chat == chat
    end
    member.nil? ? nil : member.roles
  end
end