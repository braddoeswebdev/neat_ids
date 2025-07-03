module NeatIds
  class Engine < ::Rails::Engine
    initializer "prefixed_ids.model" do
      ActiveSupport.on_load(:active_record) do
        include NeatIds::Rails
      end
    end
  end
end
