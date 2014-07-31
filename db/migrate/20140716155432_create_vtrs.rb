class CreateVtrs < ActiveRecord::Migration
  def change
    create_table :vtrs do |t|
      t.string :voterid
      t.datetime :date
      t.string :leo
      t.string :formNot
      t.string :form
      t.string :jurisdiction
      t.string :coment
      t.string :notes
      t.string :action
      t.string :election

      t.timestamps
    end
  end
end
