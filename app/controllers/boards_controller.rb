class BoardsController < ApplicationController
  def export
    Resque.enqueue(ExportBoard, current_user.id, params[:board_id])
    redirect_to dashboards_path, notice: "Exporting open cards, please check your email for the download link"
  end

  def export_archived
    Resque.enqueue(ExportBoardArchived, current_user.id, params[:board_id])
    redirect_to dashboards_path, notice: "Exporting archived cards, please check your email for the download link"
  end
end
