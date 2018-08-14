class BoardsController < ApplicationController
  def export
    # Resque.enqueue(ExportBoard, current_user.id, params[:board_id])

    require 'CSV'
    board_id = params[:board_id]
    user = User.find_by(id: current_user.id)
    board = Board.find_by(trello_board_id: board_id)

    if user.present?
      puts "OK: Started board export (open)"
      start_time = Time.now

      # Get list names
      uri = URI.parse("https://api.trello.com/1/boards/#{board_id}/lists?token=#{user.trello_token}&key=#{user.trello_key}&fields=id,name")
      response = Net::HTTP.get_response(uri)
      if response.is_a?(Net::HTTPSuccess)
        lists = JSON.parse(response.body)
      end

      # Get cards
      if user.trello_member_id.present?
        uri = URI.parse("https://api.trello.com/1/boards/#{board_id}/cards/?fields=idList,name,due,labels,idShort,shortUrl,closed&members=true&member_fields=fullName&key=#{user.trello_key}&token=#{user.trello_token}&board_lists=open&filter=visible")
        response = Net::HTTP.get_response(uri)

        if response.is_a?(Net::HTTPSuccess)
          filename = "#{board.name}.csv"
          data = JSON.parse(response.body)

          csv_string = CSV.open(Rails.root.join('tmp', filename), "w") do |csv|
            csv << [
              "List",
              "Title",
              "Description",
              "Points",
              "Due",
              "Members",
              "Labels",
              "Card #",
              "Card URL"
            ]

            data.each do |item|
              csv << [
                lists.detect { |f| f["id"] == item["idList"] }.present? ? lists.detect { |f| f["id"] == item["idList"] }["name"] : "-",
                item["name"],
                "-",
                "-",
                item["due"].present? ? DateTime.parse(item["due"]).strftime("%d/%m/%Y") : "-",
                item["members"].map{|x| x["fullName"]}.join(","),
                item["labels"].map{|x| x["name"]}.join(","),
                item["idShort"],
                item["shortUrl"]

              ]
            end
          end

          aws_upload   = AwsService.upload_csv_file(filename)
          download_url = AwsService.get_presigned_url(aws_upload.key)
          end_time = Time.now
          diff = (end_time - start_time) * 1000
          puts "OK: Download URL: #{download_url}"
          puts "OK: Completed export in #{diff} ms. Nothing to do. Yay!"
          Download.create(url: download_url)
          redirect_to dashboards_path
        end
      end
    else
      puts "ERROR: Board export failed, user not found."
    end
  end

  def export_archived
    Resque.enqueue(ExportBoardArchived, current_user.id, params[:board_id])
  end
end
