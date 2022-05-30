# frozen_string_literal: true

case Faraday::VERSION
when /\A0\./
  require 'faraday/upload_io'
when /\A1\.[0-8]\./
  # Faraday 1.x versions before 1.9 - not matched by
  # the previous clause - use `FilePart` (which must be explicitly
  # required)
  require 'faraday/file_part'
when /\A1\./
  # Later 1.x versions from 1.9 onwards automatically include the
  # `faraday-multipart` gem, which includes `Faraday::FilePart`
  require 'faraday/multipart'
else
  raise "Unexpected Faraday version #{Faraday::VERSION} - not sure how to set up " \
        "multipart support"
end

module Restforce
  if defined?(::Faraday::FilePart)
    FilePart = Faraday::FilePart

    # Deprecated
    UploadIO = Faraday::FilePart
  else
    # Handle pre-1.0 versions of faraday
    FilePart = Faraday::UploadIO
    UploadIO = Faraday::UploadIO
  end
end

# This patch is only needed with multipart-post < 2.0.0
# 2.0.0 was released in 2013.
require 'restforce/patches/parts' unless Parts::Part.method(:new).arity.abs == 4
