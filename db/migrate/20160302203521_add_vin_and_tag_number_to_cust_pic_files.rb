class AddVinAndTagNumberToCustPicFiles < ActiveRecord::Migration
  def change
    add_column :cust_pic_files, :vin_number, :string
    add_column :cust_pic_files, :tag_number, :string
  end
end
