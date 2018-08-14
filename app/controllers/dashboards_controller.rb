class DashboardsController < ApplicationController
  before_action :authenticate_user!

  def index
  end

  def settings
    @user = current_user
  end

  def get_download_url
  end
end
