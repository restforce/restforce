# frozen_string_literal: true

module Restforce
  UploadIO = Faraday::UploadIO
end

require 'restforce/patches/parts' unless Parts::Part.method(:new).arity.abs == 4
