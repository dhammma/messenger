class MessagesController < ApplicationController
  def index
    chat = Chat.find params[:chat_id]

    page = (params.include? :page) ? params[:page] : nil

    if page.present?
      per_page = (params.include? :per_page) ? params[:per_page] : 50
      messages = chat.messages.page(page).per(per_page).order(created_at: :desc)
    else
      messages = chat.messages.order(created_at: :asc)
    end

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
