# frozen_string_literal: true

%w[faraday/multipart faraday/file_part faraday/upload_io].find do |faraday|
  require faraday
rescue LoadError
  false
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
