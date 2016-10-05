class MessagesController < ApplicationController
  def index
    chat = Chat.find params[:chat_id]

    messages_number = chat.messages.size

    offset = messages_number - params[:per_page].to_i * params[:page].to_i
    offset = 0 if offset < 0

    messages = chat.messages.limit(params[:per_page]).offset(offset).order(created_at: :asc)

    render json: { messages: messages.map(&:to_api_response) }
  end

  def create
    message = Message.new message_params

    message.user = current_user
    message.save!

    render json: { message: message.to_api_response }
  end

  private
  def message_params
    parameters = params.require(:message).permit(:text)
    parameters[:chat_id] = params[:chat_id]

    parameters
  end
end
