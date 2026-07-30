# frozen_string_literal: true

module Restforce
  class AbstractClient
    include Restforce::Concerns::Base
    include Restforce::Concerns::Connection
    include Restforce::Concerns::Authentication
    include Restforce::Concerns::Caching
    include Restforce::Concerns::API
    include Restforce::Concerns::BatchAPI
    include Restforce::Concerns::SObjectCollectionAPI
    include Restforce::Concerns::SObjectTreeAPI
    include Restforce::Concerns::CompositeAPI
    include Restforce::Concerns::CompositeGraphAPI
  end
end
