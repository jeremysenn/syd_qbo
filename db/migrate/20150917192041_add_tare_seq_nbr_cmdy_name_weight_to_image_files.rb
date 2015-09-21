class AddTareSeqNbrCmdyNameWeightToImageFiles < ActiveRecord::Migration
  def change
    add_column :image_files, :tare_seq_nbr, :integer
    add_column :image_files, :commodity_name, :string
    add_column :image_files, :weight, :decimal
    
    add_column :image_files, :customer_name, :string
    add_column :image_files, :tag_number, :string
    add_column :image_files, :vin_number, :string
  end
end
