# frozen_string_literal: true

class Admin::TeamMembersController < Admin::BaseController
  before_action :require_admin_access

  def index
    @users = User.all
  end

  def edit
    @user = User.find params[:id]
  end

  def update
    @user = User.find params[:id]

    if @user == current_user
      redirect_to admin_team_members_path, alert: 'You cannot change your own role'
    else
      @user.update role: params.require(:user).fetch(:role)
      respond_with @user, location: admin_team_members_path
    end
  end
end
