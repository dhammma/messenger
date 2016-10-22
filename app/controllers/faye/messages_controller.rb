module Faye
  class MessagesController < FayeRails::Controller
    observe ::Message, :after_create do |message|
      MessagesController.publish("/chat/#{message.chat.id}/messages", message.to_api_response)
    end

    channel '/chat/*/messages' do
      filter :in do
        passed = true
        if subscribing?
          # User must be logged in
          # and be a member of current chat to subscribe
          passed = current_user && !!current_user.chats.detect do |chat|
            chat.id.to_s == channel_part(2)
          end
        end

        passed ? pass : block
      end
    end
  end
end