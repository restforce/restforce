# frozen_string_literal: true

require 'restforce/concerns/verbs'

module Restforce
  module Concerns
    module CompositeTreeAPI
      extend Restforce::Concerns::Verbs

      define_verbs :post

      def composite_tree(root, records = [])
        begin
          response = api_post("composite/tree/#{root}", { records: records }.to_json)
        rescue Restforce::ResponseError => e
          raise CompositeTreeAPIError, Hashie::Mash.new(e.response)
        end

        response.body['results']
      end
    end
  end
end

