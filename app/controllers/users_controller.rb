class UsersController < ApplicationController
  before_action :authenticate_user!

  def update
    current_user.update(user_params)
    respond_to do |format|
      format.html { redirect_to settings_dashboards_path, notice: 'Trello credentials updated!' }
    end
  end

  protected

  def user_params
    params.require(:user).permit(:trello_token, :trello_key)
  end
end
