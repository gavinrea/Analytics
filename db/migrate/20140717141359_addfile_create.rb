class AddfileCreate < ActiveRecord::Migration
  def up
    add_column :logs, :fileCreateDate, :datetime
  end

  def down
  end
end
