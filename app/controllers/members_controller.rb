class MembersController < ApplicationController
  def index
    chat = Chat.find params[:chat_id]

    render json: { members: chat.members.map(&:to_api_response) }
  end

  def create
    chat = Chat.find params[:chat_id]

    member = User.find_by_nickname!(params[:nickname])

    if chat.members.include? current_user
      # Use transaction and save! method to force members validations
      Chat.transaction do
        chat.add_member member
        chat.save!
      end

      render json: { chat: chat.to_api_response }
    else
      render json: { errors: ['You are not the member of this chat!'] }, status: 400
    end
  end

  def destroy
    if params[:nickname] == current_user.nickname
      render json: { errors: ['You try to remove yourself from the chat!'] }, status: 400 and return
    end

    chat = Chat.find params[:chat_id]
    if chat.members.include? current_user
      member = User.find_by_nickname!(params[:nickname])

      # Use transaction and save! method to force members validations
      Chat.transaction do
        chat.members.delete member
        chat.save!
      end

      render json: { chat: chat.to_api_response }
    else
      render json: { errors: ['You are not the member of this chat!'] }, status: 400
    end
  end
end