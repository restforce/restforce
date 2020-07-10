# frozen_string_literal: true

require 'spec_helper'

describe Restforce::ErrorCode do
  describe "mapping of error codes to classes" do
    subject(:error_exception_classes) { described_class::ERROR_EXCEPTION_CLASSES }

    let(:exception_classes) do
      described_class.constants.
        map { |constant_name| described_class.const_get(constant_name) }.
        select { |constant| constant.is_a?(Class) }
    end

    it "maps all defined exception classes to an error code" do
      exception_classes.each do |exception_class|
        expect(error_exception_classes.values).to include(exception_class)
      end
    end

    it "maps all error codes to a defined exception class" do
      error_exception_classes.each_value do |mapped_exception_class|
        expect(exception_classes).to include(mapped_exception_class)
      end
    end
  end

  describe '.get_exception_class' do
    context 'when a non-existent error code is looked up' do
      let(:new_error_code) { 'ANOTHER_NEW_ERROR_CODE' }
      subject              { described_class.get_exception_class(new_error_code) }

      it { should be Restforce::ResponseError }

      it 'outputs a warning' do
        expect(Warning).to receive(:warn)
        subject
      end
    end

    context 'when a known error code is looked up' do
      let(:existing_error_code) { "ALL_OR_NONE_OPERATION_ROLLED_BACK" }
      let(:existing_error)      { described_class::AllOrNoneOperationRolledBack }

      subject do
        described_class.get_exception_class(existing_error_code)
      end

      it { should < Restforce::ResponseError }

      it 'returns existing error' do
        should be(existing_error)
      end

      it 'does not output a warning' do
        expect(Warning).to_not receive(:warn)
        subject
      end
    end
  end
end
