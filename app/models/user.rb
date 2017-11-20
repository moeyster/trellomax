class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  has_and_belongs_to_many :boards

  after_save :get_trello_member_id, if: Proc.new { self.saved_change_to_trello_token? || self.saved_change_to_trello_key? }
  after_save :sync_boards, if: Proc.new { self.saved_change_to_current_sign_in_at? }

  def get_trello_member_id
    puts "Started get trello member id"
    uri = URI.parse("https://api.trello.com/1/tokens/#{self.trello_token}/member?token=#{self.trello_token}&key=#{self.trello_key}&fields=id")
    response = Net::HTTP.get_response(uri)
    if response.is_a?(Net::HTTPSuccess)
      data = JSON.parse(response.body)
      self.update_columns(trello_member_id: data["id"])
      self.sync_boards
    end
  end

  def sync_boards
    puts "Started sync boards"
    if self.trello_member_id.present?
      uri = URI.parse("https://api.trello.com/1/members/#{self.trello_member_id}/boards?token=#{self.trello_token}&key=#{self.trello_key}&filter=open&fields=id,name,dateLastActivity")
      response = Net::HTTP.get_response(uri)

      if response.is_a?(Net::HTTPSuccess)
        data = JSON.parse(response.body)
        data.each do |item|
          board = self.boards.find_or_create_by(trello_board_id: item["id"])
          board.update_attributes(name: item["name"], date_last_activity: DateTime.parse(item["dateLastActivity"]))
        end
      end
    end
  end
end
