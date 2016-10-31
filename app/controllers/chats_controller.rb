class ChatsController < ApplicationController
  def index
    klass = chat_class params[:type]
    unless klass
      render json: { errors: ['Wrong chat type!'] }, status: 400 and return
    end

    chats = klass.joins(:chat_members).includes(:members)
                .where(chat_members: { user: current_user })
                .order_by_last_message.distinct.all

    chats_info = chats.map do |chat|
      info = chat.to_api_response
      if chat.is_a? PrivateChat
        # Replace private chat title with interlocutor name
        info[:title] = '@' + chat.members.reject do |user|
          !chat.self_chat? and user.id == current_user.id
        end.first.nickname
      end

      info
    end

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
    klass = chat_class params[:type]
    unless klass
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

  def chat_class(type)
    type ||= :all
    case type.to_s.underscore.to_sym
    when :group, :group_chat
      GroupChat
    when :private, :private_chat
      PrivateChat
    when :all
      Chat
    else
      false
    end
  end
end
