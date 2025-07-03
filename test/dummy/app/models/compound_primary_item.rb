class CompoundPrimaryItem < ApplicationRecord
  self.primary_key = [:id, :user_id]

  has_neat_id :compound, minimum_length: 32, override_find: false, override_param: false

  belongs_to :user
end
