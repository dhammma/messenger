require 'rails_helper'

RSpec.describe PrivateChat, type: :model do
  describe 'create private chat' do
    def add_members(chat, count)
      count.times do
        chat.add_member create(:user)
      end
    end

    before :each do
      @chat = PrivateChat.new
      @chat.title = 'Some title'
    end

    context 'without members' do
      it 'is invalid' do
        expect(@chat.save).to be(false)
        expect(@chat.errors).to include(:chat_members)
      end
    end

    context 'with 1 member' do
      it 'is invalid' do
        add_members @chat, 1
        expect(@chat.save).to be(false)
        expect(@chat.errors).to include(:chat_members)
      end
    end

    context 'with 2 members' do
      it 'is valid' do
        add_members @chat, 2
        expect(@chat.save).to be(true)
      end
    end

    context 'with 3 members' do
      it 'is invalid' do
        add_members @chat, 3
        expect(@chat.save).to be(false)
        expect(@chat.errors).to include(:chat_members)
      end
    end
  end

  describe 'get method' do
    def it_does_not_create_chats(user1, user2)
      count_before = PrivateChat.count
      last_id_before = PrivateChat.last.id

      PrivateChat.get user1, user2

      count_after = PrivateChat.count
      last_id_after = PrivateChat.last.id

      expect(count_before).to be(count_after)
      expect(last_id_before).to be(last_id_after)
    end

    def it_creates_new_private_chat(user1, user2)
      chat = PrivateChat.get user1, user2
      expect(chat.members.to_a).to match_array([user1, user2])
      expect(chat.class).to be(PrivateChat)
      expect(chat.new_record?).to be(false)
    end

    context 'when users is different' do
      context 'when private chat between this users exists' do
        before :each do
          @chat = create :private_chat_with_members
          @users = @chat.members.to_a
        end

        it 'finds this chat' do
          detected = PrivateChat.get @users.first, @users.last
          expect(detected.id).to be(@chat.id)
        end

        it 'does not create any chats' do
          it_does_not_create_chats @users.first, @users.last
        end
      end

      context 'when private chat between this users does not exist' do
        it 'creates new private chat' do
          users = create_list(:user, 2)

          it_creates_new_private_chat users.first, users.last
        end
      end
    end

    context 'when trying to get a self chat' do
      context 'when self chat for current user exists' do
        before :each do
          @chat = create :self_chat
          @user = @chat.members.first
        end

        it 'finds this chat' do
          detected = PrivateChat.get @user, @user
          expect(detected.id).to be(@chat.id)
        end

        it 'does not create any chats' do
          it_does_not_create_chats @user, @user
        end
      end

      context 'when private chat between this users does not exist' do
        it 'creates new private chat' do
          user = create :user

          it_creates_new_private_chat user, user
        end
      end
    end
  end
end
