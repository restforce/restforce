# frozen_string_literal: true

begin
  require 'faraday/file_part'
rescue LoadError
  require 'faraday/upload_io'
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
