# frozen_string_literal: true

module Sign
  class SessionsController < ActionController::Base
    # Prevent CSRF attacks by raising an exception.
    # For APIs, you may want to use :null_session instead.
    protect_from_forgery with: :exception

    layout false

    respond_to :html

    self.responder = ApplicationResponder

    def new
      @login = Login.new
    end

    def create
      @login = Login.new login_params
      session[:user_id] = @login.user_id
      respond_with @login, location: admin_root_path
    end

    def destroy
      reset_session
      redirect_to sign_in_path
    end

    private

    def login_params
      params.require(:sign_login).permit(:email, :password)
    end
  end
end
