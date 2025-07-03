class Team < ApplicationRecord
  has_neat_id :team, fallback: false
end
