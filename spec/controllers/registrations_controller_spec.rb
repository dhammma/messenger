require 'rails_helper'

RSpec.describe RegistrationsController, type: :controller do
  include Devise::Test::ControllerHelpers

  describe 'POST create' do
    # Prepare new user data before test
    before(:each) do
      @email = 'test@example.com'

      @registration_params = {
          user: {
              email: @email,
              password: 'password',
              password_confirmation: 'password'
          },
          format: :json
      }

      @request.env['devise.mapping'] = Devise.mappings[:user]
    end

    context 'with nonexistent email' do
      before(:each) do
        post :create, @registration_params

        @body = JSON.parse @response.body
      end

      it 'creates new user' do
        expect(@body.include? 'id').to be(true)
      end

      it 'email of new user is right' do
        expect(@body.include? 'email').to be(true)
        expect(@body['email']).to eq(@email)
      end
    end

    context 'with existed email' do
      before(:each) do
        # Ensure that user with this email exists
        create :user, email: @email

        post :create, @registration_params

        @body = JSON.parse @response.body
      end

      it 'does not create user' do
        expect(@body.include? 'id').to be(false)
      end

      it 'response includes message' do
        expect(@body.include? 'message').to be(true)
      end
    end
  end
end
