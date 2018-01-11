class AddGenderAgeToUsers < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :gender, :integer, default: 0
    add_column :users, :age, :integer
  end
end
