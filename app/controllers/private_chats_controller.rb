class PrivateChatsController < ApplicationController
  def get
    target = User.find_by_nickname! params[:target]

    private_chat = PrivateChat.get(current_user, target)

    render json: { chat: private_chat.to_api_response }
  end
end
