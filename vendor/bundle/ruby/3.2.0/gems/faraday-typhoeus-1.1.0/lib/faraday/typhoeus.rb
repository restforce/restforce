# frozen_string_literal: true

require_relative 'adapter/typhoeus'
require_relative 'typhoeus/version'

module Faraday
  # Main Faraday::Typhoeus adapter namespace
  module Typhoeus
    # Register adapter so either of the following work
    # * conn.adapter Faraday::Adapter::Typhoeus
    # * conn.adapter :typhoeus
    Faraday::Adapter.register_middleware(typhoeus: Faraday::Adapter::Typhoeus)
  end
end
