class InitialCrabBucketMigration < ActiveRecord::Migration[5.0]
  def change
    create_table :bucket_blocks do |t|
      t.integer :block_number, null: false
      t.string :previous, null: false
      t.timestamp :timestamp, null: false
      t.string :transaction_merkle_root, null: false
      t.string :witness, null: false
      t.string :witness_signature, null: false
      t.timestamps null: false
    end
    
    add_index :bucket_blocks, :block_number, name: :index_bucket_blocks_on_block_number, unique: true
    
    create_table :bucket_transactions do |t|
      t.integer :block_id, null: false
      t.integer :ref_block_num, null: false
      t.integer :ref_block_prefix, limit: 8, null: false
      t.timestamp :expiration, null: false
    
      t.timestamps null: false
    end
    
    add_index :bucket_transactions, :block_id, name: :index_bucket_transactions_on_block_id
    
    create_table :bucket_operations do |t|
      t.string :type, null: false
      t.integer :transaction_id, null: false
      t.string :payload, null: false
    
      t.timestamps null: false
    end
    
    add_index :bucket_operations, :transaction_id, name: :index_bucket_operations_on_transaction_id
    add_index :bucket_operations, :type, name: :index_bucket_operations_on_type
  end
end
