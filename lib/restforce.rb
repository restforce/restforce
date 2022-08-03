# frozen_string_literal: true

require 'faraday'
require 'faraday/follow_redirects'
require 'json'
require 'jwt'

require 'restforce/version'
require 'restforce/config'

module Restforce
  autoload :AbstractClient, 'restforce/abstract_client'
  autoload :SignedRequest,  'restforce/signed_request'
  autoload :Collection,     'restforce/collection'
  autoload :Middleware,     'restforce/middleware'
  autoload :Attachment,     'restforce/attachment'
  autoload :Document,       'restforce/document'
  autoload :FilePart,       'restforce/file_part'
  autoload :UploadIO,       'restforce/file_part' # Deprecated
  autoload :SObject,        'restforce/sobject'
  autoload :Client,         'restforce/client'
  autoload :Mash,           'restforce/mash'

  module Concerns
    autoload :Authentication, 'restforce/concerns/authentication'
    autoload :Connection,     'restforce/concerns/connection'
    autoload :Picklists,      'restforce/concerns/picklists'
    autoload :Streaming,      'restforce/concerns/streaming'
    autoload :Caching,        'restforce/concerns/caching'
    autoload :Canvas,         'restforce/concerns/canvas'
    autoload :Verbs,          'restforce/concerns/verbs'
    autoload :Base,           'restforce/concerns/base'
    autoload :API,            'restforce/concerns/api'
    autoload :BatchAPI,       'restforce/concerns/batch_api'
    autoload :CompositeAPI,   'restforce/concerns/composite_api'
  end

  module Data
    autoload :Client, 'restforce/data/client'
  end

  module Tooling
    autoload :Client, 'restforce/tooling/client'
  end

  Error               = Class.new(StandardError)
  ServerError         = Class.new(Error)
  AuthenticationError = Class.new(Error)
  UnauthorizedError   = Class.new(Faraday::ClientError)
  APIVersionError     = Class.new(Error)
  BatchAPIError       = Class.new(Error)
  CompositeAPIError   = Class.new(Error)

  # Inherit from Faraday::ResourceNotFound for backwards-compatibility
  # Consumers of this library that rescue and handle Faraday::ResourceNotFound
  # can continue to do so.
  NotFoundError       = Class.new(Faraday::ResourceNotFound)

  # Inherit from Faraday::ClientError for backwards-compatibility
  # Consumers of this library that rescue and handle Faraday::ClientError
  # can continue to do so.
  ResponseError       = Class.new(Faraday::ClientError)
  MatchesMultipleError= Class.new(ResponseError)
  EntityTooLargeError = Class.new(ResponseError)

  require 'restforce/error_code'

  class << self
    # Alias for Restforce::Data::Client.new
    #
    # Shamelessly pulled from https://github.com/pengwynn/octokit/blob/master/lib/octokit.rb
    def new(*args, &block)
      data(*args, &block)
    end

    def data(*args, &block)
      Restforce::Data::Client.new(*args, &block)
    end

    def tooling(*args, &block)
      Restforce::Tooling::Client.new(*args, &block)
    end

    # Helper for decoding signed requests.
    def decode_signed_request(*args)
      SignedRequest.decode(*args)
    end
  end

  # Add .tap method in Ruby 1.8
  module CoreExtensions
    def tap
      yield self
      self
    end
  end
  Object.include Restforce::CoreExtensions unless Object.respond_to? :tap
end

if ENV['PROXY_URI']
  warn "[restforce] You must now use the SALESFORCE_PROXY_URI environment variable (as " \
       "opposed to PROXY_URI) to set a proxy server for Restforce. Please update your " \
       "environment's configuration."
end
