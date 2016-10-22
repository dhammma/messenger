module Faye
  class AuthenticationController < FayeRails::Controller
    channel '/**' do
      filter :in do
        passed = true
        if subscribing?
          if message['ext']
            uid = message['ext']['uid']
            token = message['ext']['access_token']
            client_id = message['ext']['client']

            user = uid && User.find_by_uid(uid)
          else
            user = token = client_id = nil
          end

          self.current_user = user.id if user and user.valid_token?(token, client_id)

          passed = !!current_user
        end

        passed ? pass : block
      end
    end
  end
end