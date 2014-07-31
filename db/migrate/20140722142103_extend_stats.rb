class ExtendStats < ActiveRecord::Migration
  def up
    add_column :logs, :lowdate, :datetime
    add_column :logs, :highdate, :datetime
    add_column :logs, :idcount, :integer
    add_column :logs, :eventfreqs, :blob
  end

  def down
  end
end
