# frozen_string_literal: true

require 'faraday/file_part'

module Restforce
  UploadIO = Faraday::FilePart
end

require 'restforce/patches/parts' unless Parts::Part.method(:new).arity.abs == 4
