require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'chat_roles method' do
    before :each do
      @chat = create :chat
      @user = create :user
    end

    context 'when user is not member of the chat' do
      it 'returns empty array' do
        expect(@user.chat_roles @chat).to be_nil
      end
    end

    context 'when user is a member of the chat' do
      it 'returns array of user roles' do
        test_cases = [
            [],
            [ChatMember::ROLES.first],
            ChatMember::ROLES.first.dup
        ]

        test_cases.each do |roles|
          @chat.add_member @user, roles
          actual_roles = @chat.chat_members.where(user: @user).first.roles
          expect(@user.chat_roles @chat).to match_array(actual_roles)
        end
      end
    end
  end

  describe 'nickname' do
    context 'when nickname is not set' do
      it 'cuts part from email' do
        user = build :user
        user.nickname = ''

        expect(user.save).to be(true)

        expect(user.nickname).not_to eq('')
        expect(user.email).to eq("#{user.nickname}@#{user.email[/@(.+)/, 1]}")
      end
    end

    context 'when nickname is set' do
      it 'still with no changes' do
        nickname = 'nickname'
        user = build :user
        user.nickname = nickname

        expect(user.save).to be(true)
        expect(user.nickname).to eq(nickname)
      end
    end

    context 'when nickname contains unacceptable characters' do
      it 'does not save user' do
        wrong_nicknames = ['a a', '9dfd', '-f', '&dfsf']
        wrong_nicknames.each do |nickname|
          user = build :user
          user.nickname = nickname

          expect(user.save).to be(false)
          expect(user.errors[:nickname].blank?).not_to be(true)
        end
      end
    end
  end
end
