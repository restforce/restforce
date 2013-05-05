require 'restforce/concerns/base'
require 'restforce/concerns/connection'
require 'restforce/concerns/authentication'
require 'restforce/concerns/caching'
require 'restforce/concerns/api'

module Restforce
  class AbstractClient
    include Restforce::Concerns::Base
    include Restforce::Concerns::Connection
    include Restforce::Concerns::Authentication
    include Restforce::Concerns::Caching
    include Restforce::Concerns::API
  end
end