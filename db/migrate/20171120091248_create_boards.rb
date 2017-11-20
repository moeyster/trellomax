class CreateBoards < ActiveRecord::Migration[5.1]
  def change
    create_table :boards do |t|
      t.string :name
      t.string :trello_board_id
      t.datetime :date_last_activity
      t.boolean :sync
      t.timestamps
    end

    create_table :boards_users, id: false do |t|
      t.belongs_to :user, index: true
      t.belongs_to :board, index: true
    end
  end
end
