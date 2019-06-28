# frozen_string_literal: true
require 'csv'

module Restforce
  module Bulk
    class Client < AbstractClient
      def create_job(sobject, **opts)
        body = default_options.merge(opts)
        body['object'] = sobject
        merge_headers({ 'Content-Type' => 'application/json', 'Accept' => 'application/json' })
        post(api_path, body).body['id']
      end

      def upload_job_data(jid, csv)
        merge_headers({ 'Content-Type' => 'text/csv', 'Accept' => 'application/json' })
        result = put(api_path("#{jid}/batches"), csv)
        pp result
        result.status == 201
      end

      def close_job(jid)
        merge_headers({ 'Content-Type' => 'application/json', 'Accept' => 'application/json' })
        patch(api_path(jid), { "state" => "UploadComplete" }).body['state'] == 'UploadComplete'
      end

      def get_job_status(jid)
        merge_headers({ 'Content-Type' => 'application/json', 'Accept' => 'application/json' })
        get(api_path(jid)).body['state']
      end

      def get_job_success_results(jid)
        merge_headers({ 'Content-Type' => 'application/json', 'Accept' => 'text/csv' })
        results_body = get(api_path("#{jid}/successfulResults")).body
        ::CSV.parse(results_body, headers: true).map(&:to_h)
      end

      def get_job_failed_results(jid)
        merge_headers({ 'Content-Type' => 'application/json', 'Accept' => 'text/csv' })
        results_body = get(api_path("#{jid}/failedResults")).body
        ::CSV.parse(results_body, headers: true).map(&:to_h)
      end

      private

      def api_path(path = nil)
        super("jobs/ingest/#{path}")
      end

      def default_options
        {
            'contentType' => 'CSV',
            'operation' => 'insert'
        }
      end

      def merge_headers(headers)
        @options[:request_headers].nil? ?
            @options[:request_headers] = headers :
            @options[:request_headers].merge!(headers)
      end
    end
  end
end
