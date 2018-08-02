# frozen_string_literal: true

require 'faraday'
require 'faraday_middleware'
require 'json'

require 'restforce/version'
require 'restforce/config'

module Restforce
  autoload :AbstractClient, 'restforce/abstract_client'
  autoload :SignedRequest,  'restforce/signed_request'
  autoload :Collection,     'restforce/collection'
  autoload :Middleware,     'restforce/middleware'
  autoload :Attachment,     'restforce/attachment'
  autoload :Document,       'restforce/document'
  autoload :UploadIO,       'restforce/upload_io'
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
  UnauthorizedError   = Class.new(Error)
  APIVersionError     = Class.new(Error)

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
  Object.send :include, Restforce::CoreExtensions unless Object.respond_to? :tap
end

if ENV['PROXY_URI']
  warn "[restforce] You must now use the SALESFORCE_PROXY_URI environment variable (as " \
       "opposed to PROXY_URI) to set a proxy server for Restforce. Please update your " \
       "environment's configuration."
end
