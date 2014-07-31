class AddhashAlg < ActiveRecord::Migration
  def up
    add_column :vtrs, :hashAlg, :string
  end

  def down
  end
end
