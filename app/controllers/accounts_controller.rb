class AccountsController < ApplicationController
  def signup
    user = User.new(signup_params)
    if user.save
      user = authenticate_user(user)
      headers['Authorization'] = "Bearer #{user.auth_token}"
      session[:user_id] = user.id

      sanitized_user = user.as_json(only: %i[id name email])
      render json: sanitized_user, status: :ok, location: user
    else
      render json: user.errors, status: :bad_request
    end
  end

  def login
    user = authenticate_user(nil)

    if !user.blank?
      headers['Authorization'] = "Bearer #{user.auth_token}"
      session[:user_id] = user.id

      render json: { message: "User #{user.id} authenticated" }, status: :no_content
    else
      render json: { error: 'Invalid email or password' }, status: :unauthorized
    end
  end

  def logout
    user = User.find_by(email: signup_params[:email])
    return render json: { errors: 'User not found' }, status: :not_found if user.nil?

    request.headers['Authorization'] = headers['Authorization'] = nil
    session[:user_id] = nil

    render json: { message: "You're logged out" }.as_json, status: :no_content
  end

  private

  def signup_params
    params.require(:data).permit(:name, :email, :password)
  end

  def authenticate_user(user)
    user = User.find_by(email: params.require(:data).require(:email)) unless user.present?

    return unless user&.authenticate(params.require(:data).require(:password))

    user
  end
end
