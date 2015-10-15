class CreateContracts < ActiveRecord::Migration
  def change
    create_table :contracts do |t|
      t.string :company_id
      t.string :name
      t.text :wording
      
      t.timestamps
    end
  end
end
