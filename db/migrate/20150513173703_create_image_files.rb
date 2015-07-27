class CreateImageFiles < ActiveRecord::Migration
  def change
    create_table :image_files do |t|
      t.string :name
      t.string :file
      t.integer :user_id
      t.string :ticket_number
      t.string :customer_number
      t.string :branch_code
      t.string :location
      t.string :event_code
      t.integer :image_id
      t.string :container_number
      t.string :booking_number
      t.string :contract_number
      t.boolean :hidden, :default => false
      t.integer :blob_id

      t.timestamps
    end
  end
end
