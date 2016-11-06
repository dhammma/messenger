class ContactsController < ApplicationController
  def index
    info = current_user.contacts.map do |c|
      c.to_api_response
    end

    render json: { contacts: info }
  end

  def create
    contact = User.find_by_nickname!(params[:nickname])
    current_user.contacts << contact

    render json: { contact: contact }
  end

  def destroy
    user = User.find_by_nickname!(params[:nickname])
    if user and current_user.contacts.include? user
      current_user.contacts.delete user

      render json: { messages: ["User @#{params[:nickname]} has been successfully removed from contacts!"] }
    else
      render json: { errors: ["User @#{params[:nickname]} isn't in contacts!"] }, status: 400
    end
  end
end
