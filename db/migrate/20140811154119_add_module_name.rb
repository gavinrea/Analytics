class AddModuleName < ActiveRecord::Migration
  def up
    add_column :rprocs, :module_name, :string
    add_index  :rprocs, :module_name, unique: true

    add_column :rprocs, :active, :boolean
  end

  def down
  end
end
