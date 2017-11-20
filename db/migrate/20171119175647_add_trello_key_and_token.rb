class AddTrelloKeyAndToken < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :trello_token, :string
    add_column :users, :trello_key, :string
  end
end
