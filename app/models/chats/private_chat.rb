class PrivateChat < Chat
  self.table_name = self.to_s.underscore.pluralize

  validates :chat_members, length: { is: 2 }

  def self.get(user1, user2)
    if user1.id == user2.id
      private = find_self_chat user1

      # Clone user if both user1 and user2 is the same object
      user2 = user1.clone if user2 == user1
    else
      private = find_by_members([user1, user2]).first
    end

    if private.blank?
      private = new
      private.add_member user1
      private.add_member user2
      private.title = "Private chat, users #{user1.id} and #{user2.id}"
      private.save
    end

    private
  end

  def self.get_self_chat(user)
    self.get(user, user)
  end

  # Redefine this method to let users create chat with themselves
  def check_members_uniqueness(member)
    # Do nothing
  end

  def self.find_self_chat(user)
    member = ChatMember
                 .select('COUNT("chat_members"."id")', :chat_id)
                 .having('COUNT("chat_members"."id") = 2')
                 .where(user: user).group(:chat_id).all.to_a.first

    member.present? ? find_by_id(member.chat_id) : false
  end
end
