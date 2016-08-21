
class SessionsController < Devise::SessionsController
  def create
    if User.find_by_email params[:user][:email]
      super
    else
      message = "User with email #{params[:user][:email]} does not exist!"
      render json: { message: message }
    end
  end
end