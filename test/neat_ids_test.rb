require "test_helper"

class NeatIdsTest < ActiveSupport::TestCase
  test "it has a version number" do
    assert NeatIds::VERSION
  end

  test "default alphabet" do
    assert_equal 36, NeatIds.alphabet.length
  end

  test "default minimum length" do
    assert_equal 24, NeatIds.minimum_length
  end

  test "can get prefix ID from original ID" do
    assert_equal users(:one).neat_id, User.neat_id(users(:one).id)
  end

  test "can get prefix IDs from multiple original IDs" do
    assert_equal(
      [users(:one).neat_id, users(:two).neat_id, users(:three).neat_id],
      User.neat_ids([users(:one).id, users(:two).id, users(:three).id])
    )
  end

  test "can get original ID from prefix ID" do
    assert_equal users(:one).id, User.decode_neat_id(users(:one).neat_id)
  end

  test "can get original IDs from multiple prefix IDs" do
    assert_equal(
      [users(:one).id, users(:two).id, users(:three).id],
      User.decode_neat_ids([users(:one).neat_id, users(:two).neat_id, users(:three).neat_id])
    )
  end

  test "has a prefix ID" do
    neat_id = users(:one).neat_id
    assert_not_nil neat_id
    assert neat_id.start_with?("user_")
  end

  test "can lookup by prefix ID" do
    user = users(:one)
    assert_equal user, User.find_by_neat_id(user.neat_id)
  end

  test "to param" do
    assert users(:one).to_param.start_with?("user_")
  end

  test "overridden finders" do
    user = users(:one)
    assert_equal user, User.find(user.neat_id)
  end

  test "overridden finders with multiple args" do
    user = users(:one)
    user2 = users(:two)
    assert_equal [user, user2], User.find(user.neat_id, user2.neat_id)
  end

  test "overridden finders with array args" do
    user = users(:one)
    user2 = users(:two)
    assert_equal [user, user2], User.find([user.neat_id, user2.neat_id])
  end

  test "overridden finders with single array args" do
    user = users(:one)
    assert_equal [user], User.find([user.neat_id])
  end

  test "minimum length" do
    assert_equal 24 + 5, accounts(:one).neat_id.length
  end

  test "doesn't override find when disabled" do
    assert_raises ActiveRecord::RecordNotFound do
      Account.find accounts(:one).neat_id
    end
  end

  test "doesn't override to_param when disabled" do
    account = accounts(:one)
    assert_not_equal account.neat_id, account.to_param
  end

  test "find looks up the correct model" do
    user = users(:one)
    assert_equal user, NeatIds.find(user.neat_id)
  end

  test "find with invalid prefix" do
    assert_raises NeatIds::Error do
      NeatIds.find("unknown_1")
    end
  end

  test "split_id" do
    assert_equal ["user", "1234"], NeatIds.split_id("user_1234")
  end

  test "can use a custom alphabet" do
    default_encoder = NeatIds::NeatId.new(User, "user", alphabet: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890")
    custom_encoder = NeatIds::NeatId.new(User, "user", alphabet: "5N6y2rljDQak4xgzn8ZR1oKYLmJpEbVq3OBv9WwXPMe7")

    default = default_encoder.encode(1)
    custom = custom_encoder.encode(1)

    assert_not_equal default, custom
    assert_equal default_encoder.decode(default), custom_encoder.decode(custom)
  end

  test "can change the default delimiter" do
    slash = NeatIds::NeatId.new(User, "user", delimiter: "/")

    assert slash.encode(1).start_with?("user/")
  end

  test "checks for a valid id upon decoding" do
    prefix = NeatIds::NeatId.new(User, "user")
    sqids = Sqids.new(minimum_length: NeatIds.minimum_length, alphabet: NeatIds.alphabet)

    first = prefix.encode([1])
    second = sqids.encode([1])

    assert_not_equal first.delete_prefix("user" + NeatIds.delimiter), second
    assert_equal prefix.decode(second, fallback: true), second

    decoded = sqids.decode(second)
    assert_equal decoded.size, 1
    assert_equal decoded.first, 1
  end

  # See https://github.com/jcypret/hashid-rails/pull/46/files
  test "works with fixtures" do
    assert_nothing_raised do
      users(:one)
    end
  end

  test "works with relations" do
    user = users(:one)
    assert_equal user, User.default_scoped.find(user.to_param)
  end

  test "works with has_many" do
    user = users(:one)
    post = user.posts.first
    assert_equal post, user.posts.find(post.to_param)
  end

  test "decode with fallback false returns nil for regular ID" do
    assert_nil Team._neat_id.decode(1)
  end

  test "disabled fallback allows find by prefix id" do
    team = Team.find_by(id: ActiveRecord::FixtureSet.identify(:one))
    assert_equal team, Team.find(team.neat_id)
  end

  test "disabled fallback raises an error if not neat_id" do
    assert_raises NeatIds::Error do
      Team.find(ActiveRecord::FixtureSet.identify(:one))
    end
  end

  test "find by prefixed ID on association" do
    account = accounts(:one)
    assert_equal account, account.user.accounts.find(account.neat_id)
  end

  test "calling find on an associated model without prefix id succeeds" do
    nonprefixed_item = nonprefixed_items(:one)
    user = users(:one)

    assert_equal user.nonprefixed_items.find(nonprefixed_item.id), nonprefixed_item
    assert_raises(ActiveRecord::RecordNotFound) { user.nonprefixed_items.find(9999999) }
  end

  test "calling to_param on non-persisted record" do
    assert_nil Post.new.to_param
  end

  if NeatIds::Test.rails71_and_up?
    test "compound primary - can get prefix ID from original ID" do
      assert compound_primary_items(:one).id.is_a?(Array)
      assert_equal compound_primary_items(:one).neat_id, CompoundPrimaryItem.neat_id(compound_primary_items(:one).id)
    end

    test "compound primary - checks for a valid id upon decoding" do
      prefix = NeatIds::NeatId.new(CompoundPrimaryItem, "compound")
      sqids = Sqids.new(minimum_length: NeatIds.minimum_length, alphabet: NeatIds.alphabet)

      first = prefix.encode([1, 1])
      second = sqids.encode([1, 1])

      assert_not_equal first.delete_prefix("compound" + NeatIds.delimiter), second
      assert_equal prefix.decode(second, fallback: true), second

      decoded = sqids.decode(second)
      assert_equal decoded.size, 2
      assert_equal decoded, [1, 1]

      prefix_decoded = prefix.decode(first)
      assert_equal prefix_decoded, [1, 1]
    end
  end

  test "register_prefix adds the expected prefix and model" do
    model = Class.new(ApplicationRecord) do
      def self.name
        "TestModel"
      end
    end

    NeatIds.register_prefix("test_model", model: model)
    assert_equal model, NeatIds.models["test_model"]
  end

  test "has_neat_id raises when prefix was already used" do
    assert NeatIds.models.key?("user")
    assert_raises NeatIds::Error do
      Class.new(ApplicationRecord) do
        def self.name
          "TestModel"
        end

        has_neat_id :user
      end
    end
  end

  test "encode and decode UUIDs as neat_ids" do
    uuid = "123e4567-e89b-12d3-a456-426614174000"
    encoder = NeatIds::NeatId.new(User, "user")
    neat_id = encoder.encode(uuid)
    assert neat_id.start_with?("user_")
    decoded = encoder.decode(neat_id)
    assert_equal uuid, decoded
  end

  test "encode and decode integer as neat_id" do
    num = 42
    encoder = NeatIds::NeatId.new(User, "user")
    neat_id = encoder.encode(num)
    assert neat_id.start_with?("user_")
    decoded = encoder.decode(neat_id)
    assert_equal num, decoded
  end
end
