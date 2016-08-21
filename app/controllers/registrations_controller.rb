class RegistrationsController < Devise::RegistrationsController
  def create
    if User.find_by_email params[:user][:email]
      render json: { message: "User with email #{params[:user][:email]} exists!" }
    else
      super
    end
  end
end