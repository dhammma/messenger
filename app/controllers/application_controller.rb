class ApplicationController < ActionController::API
  include DeviseTokenAuth::Concerns::SetUserByToken

  rescue_from ActiveRecord::RecordNotFound do |e|
    render json: { errors: e.to_s }, status: 400
  end

  rescue_from ActiveRecord::RecordInvalid do |e|
    render json: { errors: e.to_s }, status: 400
  end
end
