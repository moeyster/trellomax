class BoardsController < ApplicationController
  def export
    Resque.enqueue(ExportBoard, current_user.id, params[:board_id])
    redirect_to dashboards_path, notice: "Monkeys are preparing the exported data for you. It will be sent to your email when it is ready."
  end
end
