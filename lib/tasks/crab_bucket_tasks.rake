namespace :bucket do
  desc 'Display the current information of the project.'
  task info: :environment do
    puts "You are running in #{Rails.env} environment."
    puts "Blocks: #{Bucket::Block.count}"
    puts "\tTransactions: #{Bucket::Transaction.count}"
    puts "\t\tOperations: #{Bucket::Operation.count}"
    Bucket::Operation.group(:type).count.sort_by { |k, v| v }.reverse.each do |group|
      type, count = group
      type = type.split('::').last
      puts "\t\t\t#{type}: #{count}"
    end
  end

  desc "Rebuild will look for any missing blocks and save them to the database."
  task rebuild: :environment do
    Bucket::Block.rebuild! do |block|
      transaction_count = block.transactions.count
      operations_count = block.transactions.map(&:operations).map(&:count).sum
      print "Block: #{block.block_number}"
      if block.persisted?
        puts ", transactions: #{transaction_count}, operations: #{operations_count}"
      else
        puts ' (skipped)'
      end
    end
  end
  
  desc "Replay will pick up where the last block (or from a specified block number) left off and save them to the database."
  task :replay, [:from_block_number] => [:environment] do |t, args|
    from_block_number = args[:from_block_number].to_i if !!args[:from_block_number]
    Bucket::Block.replay!(from_block_number) do |block|
      transaction_count = block.transactions.count
      operations_count = block.transactions.map(&:operations).map(&:count).sum
      print "Block: #{block.block_number}"
      if block.persisted?
        puts ", transactions: #{transaction_count}, operations: #{operations_count}"
      else
        puts ' (skipped)'
      end
    end
  end
  
  desc "Stream the current blocks as they appears in the blockchain and save them to the database."
  task stream_head: :environment do
    Bucket::Block.stream_head! do |block|
      transaction_count = block.transactions.count
      operations_count = block.transactions.map(&:operations).map(&:count).sum
      print "Block: #{block.block_number}"
      if block.persisted?
        puts ", transactions: #{transaction_count}, operations: #{operations_count}"
      else
        puts ' (skipped)'
      end
    end
  end
end
