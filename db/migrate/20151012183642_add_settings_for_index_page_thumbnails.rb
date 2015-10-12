class AddSettingsForIndexPageThumbnails < ActiveRecord::Migration
  def change
    add_column :user_settings, :show_vendor_thumbnails, :boolean, :default => false
    add_column :user_settings, :show_purchase_order_thumbnails, :boolean, :default => false
    add_column :user_settings, :show_bill_thumbnails, :boolean, :default => false
    add_column :user_settings, :show_bill_payment_thumbnails, :boolean, :default => false
  end
end
