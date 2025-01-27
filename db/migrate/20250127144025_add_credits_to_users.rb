class AddCreditsToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :credits, :integer, default: 4
  end
end
