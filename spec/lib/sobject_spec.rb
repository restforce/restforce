require 'spec_helper'

describe Restforce::SObject do
  describe '#new' do
    context 'with valid options' do
      let(:record) do
        described_class.new(JSON.parse(fixture('sobject/query_success_response'))['records'].first)
      end

      subject            { record }
      it                 { should be_a Restforce::SObject }
      its(:sobject_type) { should eq 'Whizbang' }
      its(:Text_Label)   { should eq 'Hi there!' }

      describe 'child records object' do
        subject { record.Whizbangs__r }

        it { should be_a Restforce::Collection }

        describe 'each child record' do
          it 'should be a Restforce::SObject' do
            record.Whizbangs__r.each do |record|
              record.should be_a Restforce::SObject
            end
          end
        end
      end

      describe 'parent record object' do
        subject { record.ParentWhizbang__r }

        it { should be_a Restforce::SObject }
        its(:sobject_type) { should eq 'Whizbang' }
        its(:Name) { should eq 'Parent Whizbang' }
      end
    end
  end
end
