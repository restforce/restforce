# frozen_string_literal: true

require 'zlib'

module Restforce
  # Middleware to uncompress GZIP compressed responses from Salesforce.
  class Middleware::Gzip < Restforce::Middleware
    ACCEPT_ENCODING_HEADER  = 'Accept-Encoding'
    CONTENT_ENCODING_HEADER = 'Content-Encoding'
    ENCODING                = 'gzip'

    def call(env)
      env[:request_headers][ACCEPT_ENCODING_HEADER] = ENCODING if @options[:compress]
      @app.call(env).on_complete do |environment|
        on_complete(environment)
      end
    end

    def on_complete(env)
      env[:body] = decompress(env[:body]) if gzipped?(env)
    end

    # Internal: Returns true if the response is gzipped.
    def gzipped?(env)
      env[:response_headers][CONTENT_ENCODING_HEADER] == ENCODING
    end

    # Internal: Decompresses a gzipped string.
    def decompress(body)
      Zlib::GzipReader.new(StringIO.new(body)).read
    rescue Zlib::GzipFile::Error
      # We thought the response was gzipped, but it wasn't. Return the original
      # body back to the caller. See https://github.com/restforce/restforce/issues/761.
      body
    end
  end
end
