class Post < ApplicationRecord
  has_neat_id :post, override_exists: false
  belongs_to :user
end
