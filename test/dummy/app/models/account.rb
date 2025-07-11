class Account < ApplicationRecord
  has_neat_id :acct, minimum_length: 32, override_find: false, override_param: false
  belongs_to :user
end
