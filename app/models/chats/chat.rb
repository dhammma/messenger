class Chat < ActiveRecord::Base
  has_many :chat_members
  has_many :members, through: :chat_members, class_name: 'User', source: :user, before_add: :check_members_uniqueness
  belongs_to :owner, class_name: 'User'

  validates :title, presence: true

  def member_roles(member, roles = nil, strategy = :set)
    member = member.id if member.is_a? User
    chat_member = chat_members.detect do |current|
      current.user_id == member
    end

    unless roles.nil?
      roles = [roles] unless roles.is_a? Array

      case strategy
      when :set
        chat_member.roles = roles
      when :add
        chat_member.roles += roles
      when :sub
        chat_member.roles -= roles
      else
        raise 'Unknown strategy'
      end
    end

    chat_member.roles
  end

  def add_member(member, roles = nil)
    members << member
    member_roles member, roles unless roles.nil?
  end

  def check_members_uniqueness(member)
    duplicate = members.detect { |current| current == member }
    members.delete duplicate if duplicate.present?
  end

  def members_by_role(roles)
    roles = [roles] unless roles.is_a? Array
    roles = roles.map { |r| r.to_s}

    chat_members.select do |m|
      member_roles = m.user.chat_roles self
      (roles & member_roles).size == roles.size
    end.map { |m| m.user }
  end
end
