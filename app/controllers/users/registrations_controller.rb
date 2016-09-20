module Users
  class RegistrationsController < DeviseTokenAuth::RegistrationsController
    after_filter :adapt_response, only: [:create]

    def adapt_response
      response = JSON.parse response_body.first

      new_response = {}
      if response.include? 'status' and response['status'] == 'success' and response.include? 'data' and response['data'].include? 'id'
        new_response = {
            status: :success,
            user: User.find(response['data']['id']).to_api_response
        }
      elsif response.include? 'errors'
        new_response = {
            status: :error,
            errors: response['errors']['full_messages']
        }
      end

      self.response_body = new_response.to_json
    end
  end
end