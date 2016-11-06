require 'rails_helper'

RSpec.describe Contact, type: :model do
  describe 'validations' do
    context 'when owner and contact is the same' do
      it 'is invalid' do
        user = create :user

        expect { user.contacts << user }.to raise_exception(ActiveRecord::RecordInvalid)
      end
    end

    context 'when owner and contact pair has already been taken' do
      it 'is invalid' do
        user = create :user
        contact = create :user

        user.contacts << contact

        expect { user.contacts << contact }.to raise_exception(ActiveRecord::RecordInvalid)
      end
    end
  end
end
