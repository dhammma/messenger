require 'rails_helper'

RSpec.describe SessionsController, type: :controller do
  include Devise::Test::ControllerHelpers

  describe 'POST create' do
    # Prepare new session parameters
    before(:each) do
      @email = 'test@email.com'
      @password = 'password'

      @session_params = {
          user: {
              email: @email,
              password: @password,
          },
          format: :json
      }

      @request.env['devise.mapping'] = Devise.mappings[:user]
    end

    context 'when user exists' do
      before(:each) do
        # Ensure that user exists
        @user = create :user, email: @email, password: @password

        post :create, @session_params

        @body = JSON.parse @response.body
      end

      it 'starts a new session' do
        expect(@body.include? 'id').to be(true)

        expect(@controller.current_user.id).to be(@body['id'])
      end
    end

    context 'when user does not exist' do
      before(:each) do
        post :create, @session_params

        @body = JSON.parse @response.body
      end

      it 'does not start a new session' do
        expect(@controller.current_user).to be(nil)
      end

      it 'response includes message' do
        expect(@body.include? 'message').to be(true)
      end
    end
  end
end
