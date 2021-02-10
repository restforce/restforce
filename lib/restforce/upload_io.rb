# frozen_string_literal: true

if Faraday::VERSION =~ /^0\./
  require 'faraday/upload_io'
else
  require 'faraday/file_part'
end

module Restforce
  UploadIO = Faraday::UploadIO
end

require 'restforce/patches/parts' unless Parts::Part.method(:new).arity.abs == 4
