# frozen_string_literal: true

require 'restforce/concerns/verbs'

module Restforce
  module Concerns
    module SObjectTreeAPI
      extend Restforce::Concerns::Verbs

      define_verbs :post

      def composite_tree(root, records = [])
        if records.empty? && block_given?
          builder = TreeBuilder.new(root)
          yield(builder)
          records = builder.records
        end

        begin
          response = api_post("composite/tree/#{root}", { records: records }.to_json)
        rescue Restforce::ResponseError => e
          raise SObjectTreeAPIError.new(e.message, e)
        end

        response.body
      end

      class TreeBuilder
        attr_reader :root, :records

        def initialize(root)
          @root = root
          @records = []
        end

        def add(reference_id, opts = {})
          records << {
            attributes: { type: root, referenceId: reference_id }
          }.merge(opts)
        end

        def embed(association, new_root)
          new_builder = TreeBuilder.new(new_root)
          yield(new_builder)
          records.last[association] = new_builder.tree
        end

        def tree
          {
            records: records
          }
        end
      end
    end
  end
end
