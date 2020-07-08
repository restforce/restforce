# frozen_string_literal: true

require 'spec_helper'

describe Restforce::ErrorCode do
  let(:error_code_list) { described_class::ERROR_CODES }

  describe '.add_error_code' do
    context 'when a new error code is created' do
      let(:new_error_code) { 'NEW_ERROR_CODE' }
      subject              { described_class.add_error_code(new_error_code) }

      it { should < Restforce::ResponseError }

      it 'adds new class to error code hash' do
        expect(error_code_list).to include(new_error_code)
      end
    end

    context 'when an existing error is added' do
      let(:existing_error_code) { error_code_list.keys.first }
      let(:existing_error)      { error_code_list[existing_error_code] }
      subject                   { described_class.add_error_code(existing_error_code) }

      it { should < Restforce::ResponseError }

      it 'returns existing error' do
        should eq(existing_error)
      end
    end
  end

  describe '.get_exception_class' do
    context 'when a non-existent class is fetched' do
      let(:new_error_code) { 'ANOTHER_NEW_ERROR_CODE' }
      subject              { described_class.get_exception_class(new_error_code) }

      it { should < Restforce::ResponseError }

      it 'adds new class to error code hash' do
        expect(error_code_list).to include(new_error_code)
      end
    end

    context 'when an existing class is fetched' do
      let(:existing_error_code) { error_code_list.keys.last }
      let(:existing_error)      { error_code_list[existing_error_code] }
      subject do
        described_class.get_exception_class(existing_error_code)
      end

      it { should < Restforce::ResponseError }

      it 'returns existing error' do
        should eq(existing_error)
      end
    end
  end
end
