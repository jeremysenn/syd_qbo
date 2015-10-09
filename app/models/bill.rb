class Bill < ActiveRecord::Base
  
  #############################
  #     Instance Methods      #
  ############################
  
  #############################
  #     Class Methods      #
  #############################
  
  def self.create_from_purchase_order(purchase_order_service, bill_service, purchase_order)
    @purchase_order = purchase_order
    @bill = Quickbooks::Model::Bill.new
    @bill.vendor_id = @purchase_order.vendor_ref
    @bill.doc_number = @purchase_order.doc_number
    
    @purchase_order.line_items.each do |line_item|
      item_based_expense_line_detail = Quickbooks::Model::ItemBasedExpenseLineDetail.new
      item_based_expense_line_detail.unit_price = line_item.item_based_expense_line_detail.unit_price
      item_based_expense_line_detail.quantity = line_item.item_based_expense_line_detail.quantity
      item_based_expense_line_detail.item_id= line_item.item_based_expense_line_detail.item_ref

      bill_line_item = Quickbooks::Model::BillLineItem.new
      bill_line_item.detail_type = "ItemBasedExpenseLineDetail"
      bill_line_item.item_based_expense_line_detail = item_based_expense_line_detail
      bill_line_item.amount = line_item.amount
      bill_line_item.description = line_item.description
      @bill.line_items.push(bill_line_item)
    end
    
    @bill = bill_service.create(@bill)
    
    @purchase_order.po_status = "Closed"
    purchase_order_service.update(@purchase_order)
    
    return @bill
  end
  
end

