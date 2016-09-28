class ChatsController < ApplicationController
  def index
    chats = Chat.joins(:chat_members).includes(:members).where(chat_members: { user: current_user }).all

    chats_info = chats.map(&:to_api_response)

    render json: { chats: chats_info }
  end

  def show
    chat = Chat.find params[:id]

    if chat.members.include? current_user
      render json: { chat: chat.to_api_response }
    else
      render_not_chat_member
    end
  end

  def create
    klass = ''
    case params[:type].to_s.underscore
    when 'group'
      klass = GroupChat
    else
      render json: { errors: ['Wrong chat type!'] }, status: 400 and return
    end

    chat = klass.new
    chat.title = params[:title]

    chat.add_member current_user, :admin

    chat.save

    render json: { chat: chat.to_api_response }
  end

  def update
    chat = Chat.find params[:id]

    if chat.members.include? current_user
      chat.update chat_parameters

      render json: { chat: chat.to_api_response }
    else
      render_not_chat_member
    end
  end

  def leave
    chat = Chat.find params[:id]

    if chat.members.include? current_user
      chat.members.delete current_user

      render json: {}
    else
      render_not_chat_member
    end
  end

  def destroy
    chat = Chat.find params[:id]

    if chat.members.include? current_user
      chat.destroy
      render json: {}
    else
      render_not_chat_member
    end
  end

  private
  def chat_parameters
    params.permit(:title)
  end

  def render_not_chat_member
    render json: { errors: ['You are not the member of this chat!'] }, status: 400
  end
end
