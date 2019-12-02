# frozen_string_literal: true

require 'spec_helper'

describe Restforce::Middleware::RaiseError do
  let(:body)       { JSON.parse(fixture('sobject/query_error_response')) }
  let(:env)        { { status: status, body: body } }
  let(:middleware) { described_class.new app }

  describe '.on_complete' do
    subject(:on_complete) { middleware.on_complete(env) }

    context 'when the status code is 404' do
      let(:status) { 404 }

      it 'raises Restforce::NotFoundError' do
        expect { on_complete }.to raise_error Restforce::NotFoundError,
                                              'INVALID_FIELD: error_message'
      end

      it 'raises an error that inherits from Faraday::ResourceNotFound' do
        expect { on_complete }.to raise_error Faraday::ResourceNotFound
      end
    end

    context 'when the status code is 300' do
      let(:status) { 300 }

      it 'raises Restforce::MatchesMultipleError' do
        expect { on_complete }.to raise_error Restforce::MatchesMultipleError,
                                              /300: The external ID provided/
      end

      it 'raises an error that inherits from Faraday::ClientError' do
        expect { on_complete }.to raise_error Faraday::ClientError
      end
    end

    context 'when the status code is 400' do
      let(:status) { 400 }

      it "raises an error derived from the response's errorCode" do
        expect { on_complete }.to raise_error Restforce::ErrorCode::InvalidField,
                                              'INVALID_FIELD: error_message'
      end

      it 'raises an error that inherits from Faraday::ClientError' do
        expect { on_complete }.to raise_error Faraday::ClientError
      end
    end

    context 'when the status code is 401' do
      let(:status) { 401 }

      it 'raises Restforce::UnauthorizedError' do
        expect { on_complete }.to raise_error Restforce::UnauthorizedError,
                                              'INVALID_FIELD: error_message'
      end
    end

    context 'when the status code is 413' do
      let(:status) { 413 }

      it 'raises Restforce::EntityTooLargeError' do
        expect { on_complete }.to raise_error Restforce::EntityTooLargeError,
                                              '413: Request Entity Too Large'
      end

      it 'raises an error that inherits from Faraday::ClientError' do
        expect { on_complete }.to raise_error Faraday::ClientError
      end
    end

    context 'when status is 400+ and body is a string' do
      let(:body)   { 'An error occured' }
      let(:status) { 400 }

      it 'raises a generic Faraday::ClientError' do
        expect { on_complete }.to raise_error Faraday::ClientError,
                                              "(error code missing): #{body}"
      end

      it 'raises an error that inherits from Faraday::ClientError' do
        expect { on_complete }.to raise_error Faraday::ClientError,
                                              "(error code missing): #{body}"
      end
    end
  end
end
