require 'rails_helper'

RSpec.describe Chat, type: :model do
  describe 'member_roles method' do
    before :each do
      @initial_roles = ChatMember::ROLES - [ChatMember::ROLES.first]

      @chat = create :chat_with_member
      @member = @chat.members.first

      @chat.chat_members.each do |chat_member|
        @chat_member = chat_member if chat_member.user == @member
        @chat_member.roles = @initial_roles
      end
    end

    context 'with unknown strategy' do
      it 'raises an exception' do
        expect { @chat.member_roles @member, [], :unknown }.to raise_error(RuntimeError)
      end
    end

    context 'with array of roles and :set strategy' do
      it 'sets roles to argument value' do
        test_member_roles :set
      end
    end

    context 'with :add strategy' do
      it 'adds argument value to member roles' do
        test_member_roles :add do |current_case|
          current_case | @initial_roles
        end
      end
    end

    context 'with :sub strategy' do
      it 'subtracts argument value from member roles' do
        test_member_roles :sub do |current_case|
          @initial_roles - current_case
        end
      end
    end

    def test_member_roles(strategy)
      test_cases = [
          # Array of roles
          ChatMember::ROLES.dup,
          [ChatMember::ROLES.first],
          [ChatMember::ROLES.first.to_sym],
          [],

          # Single roles
          ChatMember::ROLES.first,
          ChatMember::ROLES.first.to_sym
      ]

      test_cases.each do |current_case|
        result = @chat.member_roles @member, current_case, strategy

        # Ensure that current case is an Array in order to unify next inspections
        current_case = [current_case] unless current_case.is_a? Array

        # Method returns array of string roles,
        # so we should convert roles (it could be Symbol) to strings before comparison
        current_case.map! { |r| r.to_s }

        # Delegate building of the expected result to the block
        new_roles = block_given? ? yield(current_case) : current_case

        expect(result).to match_array(new_roles)
        expect(result).to match_array(@chat.member_roles @member)
        expect(result).to match_array(@chat_member.roles)

        # Return member roles to initial state
        @chat_member.roles = @initial_roles
      end
    end
  end

  describe 'members association' do
    before :each do
      @chat = create :chat_with_member
      @member = @chat.members.first
    end

    context 'when association is not unique' do
      it 'saves it only one time' do
        @chat.members << create(:user)
        @chat.members << @member
        expect(@chat.members.uniq).to match_array(@chat.members)
      end
    end
  end

  describe 'members_by_role method' do
    context 'when chat contains members with required roles' do
      it 'returns list of members with this roles' do
        chat = create :chat_with_members, members: [
            { roles: ChatMember::ROLES.first },
            { roles: ChatMember::ROLES.last },
            { roles: ChatMember::ROLES.dup }
        ]

        [
            ChatMember::ROLES.first,
            [ChatMember::ROLES.last],
            ChatMember::ROLES.dup
        ].each do |roles|
          members = chat.members_by_role roles

          roles = [roles] unless roles.is_a? Array

          members.each do |member|
            expect(member).to be_a(User)

            member_roles = member.chat_roles chat
            expect((roles & member_roles).size).to be(roles.size)
          end
        end
      end
    end

    context 'when chat does not contain members with required roles' do
      it 'returns empty array' do
        chat = create :chat_with_members, members: [
            { roles: ChatMember::ROLES.first },
            { roles: ChatMember::ROLES.first },
            { roles: ChatMember::ROLES.first }
        ]

        [
            ChatMember::ROLES.last,
            [ChatMember::ROLES.last],
            ChatMember::ROLES.dup
        ].each do |roles|
          members = chat.members_by_role roles

          roles = [roles] unless roles.is_a? Array

          members.each do |member|
            expect(member).to be_a(User)

            member_roles = member.chat_roles chat
            expect((roles & member_roles).size).to be(0)
          end
        end
      end
    end
  end

  describe 'find_by_members class method' do
    context 'when sought-for chat exists' do
      def test_all_user_combinations
        @users.size.times do |i|
          # Use (i + 1) because it starts from 0
          @users.combination(i + 1).each do |combination|
            detected = Chat.find_by_members(combination).to_a
            expect(detected.map { |e| e.id }).to match_array(@chats.map { |e| e.id })
          end
        end
      end

      before :each do
        @chat = build :chat

        @users = create_list(:user, 4)

        @users.each do |user|
          @chat.add_member user
        end

        @chat.save

        # Array of chat that have to be found
        @chats = [@chat]
      end

      context 'and it is the only one' do
        it 'finds this chat' do
          test_all_user_combinations
        end
      end

      context 'and it is not the only one' do
        before :each do
          @chat2 = build :chat

          @users.each do |user|
            @chat2.add_member user
          end

          # Add additional users
          @chat2.add_member create(:user)
          @chat2.add_member create(:user)

          @chat2.save

          @chats << @chat2

          # Create chat that must not be found
          @chat3 = build :chat
          6.times { @chat2.add_member create(:user) }
          @chat3.save
        end

        it 'finds the both chats' do
          test_all_user_combinations
        end
      end
    end

    context 'when sought-for chat does not exist' do
      before :each do
        # Create 6 chats with random members
        6.times do
          members = Array.new(3 + rand(4)).fill({ roles: [:member] })
          create(:chat_with_members, members: members)
        end
      end

      it 'finds nothing' do
        test_cases = [
            create(:user),
            create_list(:user, 2),
            create_list(:user, 3)
        ]

        test_cases.each do |members|
          detected = Chat.find_by_members(members)
          expect(detected.size).to be(0)
        end
      end
    end
  end

  describe 'order_by_last_message scope' do
    context 'with wrong argument' do
      it 'raises ArgumentError' do
        test_cases = [:symbol, 'string', []]
        test_cases.each do |tet_case|
          expect { Chat.order_by_last_message tet_case }.to raise_error(ArgumentError)
        end

        chat = create :chat_with_members
        chat
      end
    end

    context 'with right argument' do
      it 'returns ordered relation' do
        create_list :chat_with_members, 5

        chats = Chat.order_by_last_message(:desc).all.to_a
        sorted = chats.sort_by do |chat|
          chat.messages.order(created_at: :desc).first.created_at
        end.reverse

        expect(sorted == chats).to be(true)
      end
    end
  end
end