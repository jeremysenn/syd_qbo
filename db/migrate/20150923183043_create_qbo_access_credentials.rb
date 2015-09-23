class CreateQboAccessCredentials < ActiveRecord::Migration
  def change
    create_table :qbo_access_credentials do |t|
      t.integer :user_id
      t.string :access_token
      t.string :access_secret
      t.string :company_id
      t.datetime :token_expires_at
      t.datetime :reconnect_token_at
      
      t.timestamps
    end
  end
end
