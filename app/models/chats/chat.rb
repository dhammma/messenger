class Chat < ActiveRecord::Base
  has_many :chat_members
  has_many :members, through: :chat_members, class_name: 'User', source: :user, before_add: :check_members_uniqueness
  has_many :messages

  def self.order_by_last_message(order = 'DESC')
    order = order.to_s.upcase
    raise ArgumentError.new('Order can be only ASC or DESC!') unless %w(ASC DESC).include? order

    # Prepare subquery SQL. It contains last message date and chat id
    subquery = Message.select('MAX("created_at") AS "last_message_date"', :chat_id).group(:chat_id).to_sql

    # Memorize relation to get it values attribute.
    # It contains information about each query part (select, form, etc.)
    relation = joins('LEFT JOIN (' + subquery + ') "order_by_last_message" ON "' + table_name + '"."id" = "order_by_last_message"."chat_id"')
                   .order('"order_by_last_message"."last_message_date" ' + order)

    # If relation select section is empty,
    # add all fields from model table to make it behave as expected
    relation = relation.select('"' + table_name + '".*') unless relation.values[:select]
    relation.select('"order_by_last_message"."last_message_date"')
  end

  scope :find_by_members, (-> (users) do
    users = [users] unless users.is_a? Array
    users = users.map do |current|
      exclude = users.dup
      exclude.delete(current)

      { include: current, exclude: exclude }
    end

    user_chats = users.map do |p|
      ChatMember
          .where(user: p[:include])
          .where.not(user: p[:exclude])
          .select(:chat_id).all.map { |m| m.chat_id }
    end

    if user_chats.size > 1
      chats = user_chats[0] & user_chats[1]
      (user_chats.size - 2).times do |n|
        chats &= user_chats[n + 2]
      end
    else
      chats = user_chats
    end

    where(id: chats.flatten)
  end)

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
    duplicate = members.detect { |current| current.id == member.id }
    members.delete duplicate if duplicate.present?
  end

  def members_by_role(roles)
    roles = [roles] unless roles.is_a? Array
    roles = roles.map { |r| r.to_s }

    chat_members.select do |m|
      member_roles = m.user.chat_roles self
      (roles & member_roles).size == roles.size
    end.map { |m| m.user }
  end

  def to_api_response
    chat_info = super
    chat_info[:title] = title
    chat_info[:members] = members.map(&:to_api_response)

    chat_info
  end
end
