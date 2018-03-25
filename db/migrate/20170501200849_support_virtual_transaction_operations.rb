class SupportVirtualTransactionOperations < ActiveRecord::Migration[5.0]
  def up
    change_column :bucket_operations, :transaction_id, :integer, null: true
    add_column :bucket_operations, :block_id, :integer, default: -1, null: false
    
    Bucket::Operation.join(:transaction).update_all("block_id = transaction.block_id")
  end
  
  def down
    change_column :bucket_operations, :transaction_id, :integer, null: false
    remove_column :bucket_operations, :block_id
  end
end
