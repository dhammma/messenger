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
end
