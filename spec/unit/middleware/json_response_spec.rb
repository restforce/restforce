# frozen_string_literal: true

require 'spec_helper'

describe Restforce::Middleware::JsonResponse do
  let(:parser_options) { nil }
  let(:content_type) { 'application/json' }
  let(:body) { '{"Id":"001D000000INjVeIAL"}' }
  let(:env) { { body: body, response_headers: { 'Content-Type' => content_type } } }

  subject(:middleware) { described_class.new(parser_options: parser_options) }

  def parsed_body
    middleware.on_complete(env)
    env[:body]
  end

  it 'parses the body' do
    expect(parsed_body).to eq('Id' => '001D000000INjVeIAL')
  end

  it 'passes no options to JSON.parse' do
    expect(JSON).to receive(:parse).with(body).and_call_original
    parsed_body
  end

  context 'with parser_options' do
    let(:parser_options) { { symbolize_names: true } }

    it 'applies them to the parsed body' do
      expect(parsed_body).to eq(Id: '001D000000INjVeIAL')
    end

    it 'passes them to JSON.parse as keyword arguments' do
      expect(JSON).to receive(:parse).with(body, symbolize_names: true).and_call_original
      parsed_body
    end
  end

  context 'with a blank body' do
    let(:body) { ' ' }

    it 'sets the body to nil' do
      expect(parsed_body).to be_nil
    end
  end

  context 'with a non-JSON content type' do
    let(:content_type) { 'text/plain' }

    it 'leaves the body unparsed' do
      expect(parsed_body).to eq(body)
    end
  end
end
