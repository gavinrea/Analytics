class FixCommentName < ActiveRecord::Migration
  def up  
    rename_column :vtrs, :coment, :comment
  end

  def down
  end

end
