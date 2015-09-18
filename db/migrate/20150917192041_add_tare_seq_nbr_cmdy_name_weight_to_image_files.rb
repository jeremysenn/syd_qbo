class AddTareSeqNbrCmdyNameWeightToImageFiles < ActiveRecord::Migration
  def change
    add_column :image_files, :tare_seq_nbr, :integer
    add_column :image_files, :cmdy_name, :string
    add_column :image_files, :weight, :decimal
  end
end
