class AddQuickbooksAttachmentInfoToImageFiles < ActiveRecord::Migration
  def change
    add_column :image_files, :quickbooks_expense_type, :string
    add_column :image_files, :quickbooks_expense_id, :integer
  end
end
