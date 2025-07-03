# NeatIds
Generate neat, Stripe-style prefixed IDs for your models with [Sqids](https://sqids.org/ruby). Works with numeric OR UUID-esque primary keys!

Heavily inspired by [`prefixed_ids`](https://github.com/excid3/prefixed_ids)

## Usage
How to use my plugin.

## Installation
Add this line to your application's Gemfile:

```ruby
gem "neat_ids"
```

And then execute:
```bash
$ bundle
```

Or install it yourself as:
```bash
$ gem install neat_ids
```

Add `has_neat_id :my_prefix` to your models (before you define any associations!!) to autogenerate prefixed IDs.

```ruby
class User < ApplicationRecord
  has_neat_id :user
end
```

### Neat ID Param

By default, Neat IDs overrides `to_param` in the model to use prefix IDs.

To get the Neat ID for a record:

```ruby
@user.to_param
#=> "user_12345abcd"
```

If `to_param` override is disabled:

```ruby
@user.neat_id
#=> "user_12345abcd"
```

#### Query by Neat ID

By default, neat_ids overrides `find` and `to_param` to seamlessly URLs automatically.

```ruby
User.first.to_param
#=> "user_5vJjbzXq9KrLEMm32iAnOP0xGDYk6dpe"

User.find("user_5vJjbzXq9KrLEMm32iAnOP0xGDYk6dpe")
#=> #<User>
```

> [!NOTE]
> `find` still finds records by primary key. For example, `User.find(1)` still works.

You can also use `find_by_neat_id` or `find_by_neat_id!` when the `find` override is disabled:

```ruby
User.find_by_neat_id("user_5vJjbzXq9KrLEMm32iAnOP0xGDYk6dpe") # Returns a User or nil
User.find_by_neat_id!("user_5vJjbzXq9KrLEMm32iAnOP0xGDYk6dpe") # Raises an exception if not found
```

To disable `find` and `to_param` overrides, pass the following options:

```ruby
class User < ApplicationRecord
  has_neat_id :user, override_find: false, override_param: false
end
```

> [!NOTE]
> If you're aiming to masking primary key ID for security reasons, make sure to use `find_by_neat_id`.

### Find Any Model By Neat ID

Imagine you have a Neat ID but you don't know which model it belongs to:

```ruby
NeatIds.find("user_5vJjbzXq9KrLEMm3")
#=> #<User>

NeatIds.find("acct_2iAnOP0xGDYk6dpe")
#=> #<Account>
```

This works similarly to GlobalIDs.

### Customizing Neat IDs

You can customize the prefix, length, and attribute name for NeatIds.

```ruby
class Account < ApplicationRecord
  has_neat_id :acct, minimum_length: 32, override_find: false, override_param: false, fallback: false
end
```

By default, `find` will accept both Neat IDs and regular IDs. Setting `fallback: false` will disable finding by regular IDs and will only allow Neat IDs.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/braddoeswebdev/neat_ids. 

Contributors are expected to adhere to the [code of conduct](https://github.com/braddoeswebdev/neat_ids/blob/master/CODE_OF_CONDUCT.md).

## License
The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
