class User < ActiveRecord::Base
  # Include default devise modules.. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  include DeviseTokenAuth::Concerns::User

  has_many :chat_members
  has_many :chats, through: :chat_members
  has_many :messages

  has_many :contact_relations
  has_many :contacts, through: :contact_relations, class_name: 'User'

  validates :nickname, uniqueness: true,
            format: { with: /\A[a-zA-Z][a-zA-Z0-9_\-\.]+\Z/,
                      message: 'only allows letters, numbers, points, dashes and underscores' }

  before_validation :set_nickname

  def chat_roles(chat)
    member = chat_members.detect do |m|
      m.chat == chat
    end
    member.nil? ? nil : member.roles
  end

  def set_nickname
    if nickname.blank?
      self.nickname = email.to_s[/([^@]*)/, 1]
    end
  end

  def to_api_response
    user_info = super
    user_info[:nickname] = nickname
    user_info[:email] = email

    user_info
  end
end