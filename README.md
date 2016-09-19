# CrabBucket - a Rails Plugin

```sql
SELECT * FROM bucket_blocks AS blocks
  INNER JOIN bucket_transactions transactions
    ON transactions.block_id = blocks.id
  WHERE witness = ?
```

The main purpose of this project is to give developers a way to build a copy of
the STEEM blockchain to a local database for reporting and analysis.

It's not intended to copy the whole blockchain, but there's nothing stopping
anyone from trying this.  It just might take a while.  If you do intend to copy
the entire blockchain, you will need to use a local node.  Otherwise, it'll take
months (or years, if you're reading this in the Mysterious Future).

## How to use the CrabBucket Rails Plugin

There are two main uses.  One, is to embed it in your existing rails project.
The other is to just run it in a new project for the sole purpose of building a
database for external tools to use.

To start populating the database, you have a few options.  This will populate
from the first block.  Use this if you have a fast local node and you want to
import the entire blockchain.

```bash
$ rake bucket:replay
```

Or, to specify a specific block to start on:

```bash
$ rake bucket:replay[5000000]
```

Or, to start populating from the latest block forward, this will follow the head
block.

```bash
$ rake bucket:stream_head
```

Or finally, if you would like to fill in any gaps ...

```bash
$ rake bucket:rebuild
```

You can always interrupt these tasks with `^C` (Control-C) and resume them
later.  You can check your progress with:

```bash
$ rake bucket:info
```

Which will output the current state:

```
You are running in development environment.
Blocks: 4187
	Transactions: 237
		Operations: 237
			Pow: 237
```

Once the database is populated to your liking, querying the database with
`ActiveRecord` is as follows:

```bash
$ rails console
```

Then type in the console:

```ruby
Bucket::Block.first
```

Which will output:

```
  Bucket::Block Load (0.2ms)  SELECT  "bucket_blocks".* FROM "bucket_blocks"
ORDER BY "bucket_blocks"."id" ASC LIMIT ?  [["LIMIT", 1]]
 => #<Bucket::Block id: 1, block_number: 1, previous:
"0000000000000000000000000000000000000000", timestamp: "2016-03-24 16:05:00",
transaction_merkle_root: "0000000000000000000000000000000000000000", witness:
"initminer", witness_signature:
"204f8ad56a8f5cf722a02b035a61b500aa59b9519b2c33c77a...", created_at:
"2016-09-19 16:14:31", updated_at: "2016-09-19 16:14:31">
```

```ruby
Bucket::Operation.pow.first.work.worker
```

Output:

```
  Bucket::Operation Load (0.4ms)  SELECT  "bucket_operations".* FROM "bucket_operations" WHERE "bucket_operations"."type" = ? ORDER BY "bucket_operations"."id" ASC LIMIT ?  [["type", "Bucket::Operation::Pow"], ["LIMIT", 1]]
 => "STM65wH1LZ7BfSHcK69SShnqCAH5xdoSZpGkUjmzHJ5GCuxEK9V5G"
```

Or, if you just want to browse, start your `rails server` and browse to:

[http://localhost:3000/crab_bucket/blocks](http://localhost:3000/crab_bucket/blocks)

Or, you can use an external tool,  The database can be found in:

`/path/to/your/project/db/development.sqlite`

## Installation

### For Existing Rails Projects

Assuming you already have an existing rails project,

Add this line to your application's Gemfile:

```ruby
gem 'radiator', '~> 0.0.4', github: 'inertia186/radiator'
gem 'crab-bucket', '~> 0.0.4', github: 'inertia186/crab-bucket'
```

And then execute:
```bash
$ bundle
```

Add this to your routes, before the last `end` keyword:

```ruby
mount Bucket::Engine, at: '/crab_bucket'
```

Install the migrations:

```bash
$ rails bucket:install:migrations
$ rake db:migrate
$ rake bucket:stream_head # optional, see above
```

### For New Projects

Have a look at this article on setting up a new rails project, then use the
steps above to enable this plug-in.

[How to Write a Ruby on Rails App for STEEM](https://steemit.com/radiator/@inertia/how-to-write-a-ruby-on-rails-app-for-steem)

## Tests

* Basic tests can be invoked as follows:
  * `rake`
* To run tests with parallelization and local code coverage:
  * `HELL_ENABLED=true rake`
  
![Temporary Image](https://www.steemimg.com/images/2016/09/19/bucket_of_crabs_cutout-rbe030e040d404730b933ea92b20c6937_x7saw_8byvr_324f4aa5.jpg)

## Get in touch!

If you're using CrabBucket, I'd love to hear from you.  Drop me a line and tell
me what you think!  I'm @inertia on STEEM.
  
## License

I don't believe in intellectual "property".  If you do, consider CrabBucket as
licensed under a Creative Commons [![CC0](http://i.creativecommons.org/p/zero/1.0/80x15.png)](http://creativecommons.org/publicdomain/zero/1.0/) License.
