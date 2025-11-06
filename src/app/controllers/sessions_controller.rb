# frozen_string_literal: true

class SessionsController < ApplicationController
  skip_before_action :require_login, only: %i[new create]
  skip_before_action :verify_authenticity_token, only: :create

  def new
  end

  def create
    user = User.find_by(email: params[:email])
    if user&.authenticate(params[:password])
      session[:user_id] = user.id
      respond_to do |format|
        format.html { redirect_to tasks_path, notice: "ログインしました" }
        format.json { render json: { message: "ログインしました" }, status: :created }
      end
    else
      respond_to do |format|
        format.html do
          flash.now[:alert] = "メールアドレスまたはパスワードが正しくありません"
          render :new, status: :unauthorized
        end
        format.json { render json: { error: "invalid_credentials" }, status: :unauthorized }
      end
    end
  end

  def destroy
    reset_session
    respond_to do |format|
      format.html { redirect_to new_session_path, notice: "ログアウトしました" }
      format.json { head :no_content }
    end
  end
end
