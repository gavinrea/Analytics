class FixFormNoteName < ActiveRecord::Migration
  def up
    rename_column :vtrs, :formNot, :formNote
  end

  def down
  end
end
