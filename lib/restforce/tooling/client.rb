module Restforce
  module Tooling
    class Client < AbstractClient
      private

        def api_path(path)
          super("tooling/#{path}")
        end
    end
  end
end
