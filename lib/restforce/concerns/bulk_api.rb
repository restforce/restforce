# frozen_string_literal: true

require 'restforce/concerns/verbs'

module Restforce
  module Concerns
    module BulkAPI
      extend Restforce::Concerns::Verbs

      define_verbs :post

      class Job
        attr_reader :id, :object_name, :external_key

        def initialize(object_name:, external_key:)
          @object_name = object_name
          @external_key = external_key
        end
      end
    end
  end
end
