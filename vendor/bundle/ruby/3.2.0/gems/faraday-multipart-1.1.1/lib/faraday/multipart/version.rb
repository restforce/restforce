# frozen_string_literal: true

module Faraday
  # #:nodoc:
  module Multipart
    VERSION = '1.1.1'

    def self.multipart_post_version
      require 'multipart/post/version'
      ::Gem::Version.new(::Multipart::Post::VERSION)
    rescue LoadError
      require 'multipart_post'
      ::Gem::Version.new(::MultipartPost::VERSION)
    end
  end
end
