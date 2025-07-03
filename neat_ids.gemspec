require_relative "lib/neat_ids/version"

Gem::Specification.new do |spec|
  spec.name = "neat_ids"
  spec.version = NeatIds::VERSION
  spec.authors = ["Brad Thompson"]
  spec.email = ["bkt@brad-thompson.com"]
  spec.summary = "Neat IDs generates IDs with friendly prefixes for your models"
  spec.description = "Neat IDs generates IDs with friendly prefixes for your models"
  spec.homepage = "https://github.com/braddoeswebdev/neat_ids"
  spec.license = "MIT"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/braddoeswebdev/neat_ids"
  spec.metadata["changelog_uri"] = "https://github.com/braddoeswebdev/neat_ids"

  spec.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]

  spec.add_dependency "rails", ">= 6.0.0"
  spec.add_dependency "sqids", "~> 0.2.0"
end
