require 'faraday/upload_io'

module Restforce
  UploadIO = Faraday::UploadIO
end

unless Parts::Part.method(:new).arity.abs == 4
  require 'restforce/patches/parts'
end
