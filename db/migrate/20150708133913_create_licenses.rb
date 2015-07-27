class CreateLicenses < ActiveRecord::Migration
  def change
    create_table :licenses do |t|
      t.boolean :license_valid, :default => true
    end
  end
end
