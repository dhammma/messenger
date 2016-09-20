module Users
  class PasswordsController < DeviseTokenAuth::PasswordsController
    after_filter :adapt_response, only: [:update]

    def adapt_response
      response = JSON.parse response_body.first

      new_response = {}
      if response.include? 'data' and response['data'].include? 'id'
        new_response = {
            status: :success,
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