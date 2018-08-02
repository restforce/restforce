# frozen_string_literal: true

require 'faraday/upload_io'

module Restforce
  UploadIO = Faraday::UploadIO
end

require 'restforce/patches/parts' unless Parts::Part.method(:new).arity.abs == 4
