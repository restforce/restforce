require 'restforce/client/base'
require 'restforce/client/connection'
require 'restforce/client/authentication'
require 'restforce/client/streaming'
require 'restforce/client/picklists'
require 'restforce/client/caching'
require 'restforce/client/canvas'
require 'restforce/client/api'

module Restforce
  class Client
    include Restforce::Client::Base
    include Restforce::Client::Connection
    include Restforce::Client::Authentication
    include Restforce::Client::Streaming
    include Restforce::Client::Picklists
    include Restforce::Client::Caching
    include Restforce::Client::Canvas
    include Restforce::Client::API

    # Public: Returns a url to the resource.
    #
    # resource - A record that responds to to_sparam or a String/Fixnum.
    #
    # Returns the url to the resource.
    def url(resource)
      "#{instance_url}/#{(resource.respond_to?(:to_sparam) ? resource.to_sparam : resource)}"
    end
  end
end
