# frozen_string_literal: true

require 'restforce/concerns/verbs'

module Restforce
  module Concerns
    module CompositeAPI
      extend Restforce::Concerns::Verbs

      define_verbs :post

      def composite(all_or_none: false, collate_subrequests: false)
        subrequests = Restforce::Concerns::SubRequests::CompositeSubrequests.new(options)
        yield(subrequests)

        if subrequests.requests.length > 25
          raise ArgumentError, 'Cannot have more than 25 subrequests.'
        end

        properties = {
          compositeRequest: subrequests.requests,
          allOrNone: all_or_none,
          collateSubrequests: collate_subrequests
        }
        response = api_post('composite', properties.to_json)

        results = response.body['compositeResponse']
        has_errors = results.any? { |result| result['httpStatusCode'].digits.last == 4 }
        if all_or_none && has_errors
          last_error_index = results.rindex { |result| result['httpStatusCode'] != 412 }
          last_error = results[last_error_index]
          raise CompositeAPIError.new(last_error['body'][0]['errorCode'], response)
        end

        results
      end

      def composite!(collate_subrequests: false, &block)
        composite(all_or_none: true, collate_subrequests: collate_subrequests, &block)
      end
    end
  end
end
