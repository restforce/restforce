# frozen_string_literal: true

require 'spec_helper'

describe Restforce::Concerns::API do
  let(:response) { double('Faraday::Response', body: double('Body')) }

  describe '.user_info' do
    subject(:user_info) { client.user_info }

    it 'returns the user info from identity url' do
      identity_url = double('identity_url')
      response.body.stub(:identity).and_return(identity_url)
      client.should_receive(:api_get).with(no_args).and_return(response)

      identity = double('identity')
      identity.stub(:body).and_return(identity)
      client.should_receive(:get).with(identity_url).and_return(identity)

      expect(user_info).to eq identity
    end
  end

  describe '.get_updated' do
    let(:start_date_time) { Time.new(2002, 10, 31, 2, 2, 2, "+02:00") }
    let(:end_date_time) { Time.new(2003, 10, 31, 2, 2, 2, "+02:00") }
    let(:sobject) { 'Whizbang' }
    subject(:results) { client.get_updated(sobject, start_date_time, end_date_time) }
    it 'returns the body' do
      start_string = '2002-10-31T00:02:02Z'
      end_string = '2003-10-31T00:02:02Z'
      url = "sobjects/Whizbang/updated/?start=#{start_string}&end=#{end_string}"
      client.should_receive(:api_get).
        with(url).
        and_return(response)
      expect(results).to eq response.body
    end
  end

  describe '.get_deleted' do
    let(:start_date_time) { Time.new(2002, 10, 31, 2, 2, 2, "+02:00") }
    let(:end_date_time) { Time.new(2003, 10, 31, 2, 2, 2, "+02:00") }
    let(:sobject) { 'Whizbang' }
    subject(:results) { client.get_deleted(sobject, start_date_time, end_date_time) }
    it 'returns the body' do
      start_string = '2002-10-31T00:02:02Z'
      end_string = '2003-10-31T00:02:02Z'
      url = "sobjects/Whizbang/deleted/?start=#{start_string}&end=#{end_string}"
      client.should_receive(:api_get).
        with(url).
        and_return(response)
      expect(results).to eq response.body
    end
  end

  describe '.list_sobjects' do
    subject { client.list_sobjects }

    before do
      client.stub describe: [{ 'name' => 'foo' }]
    end

    it { should eq ['foo'] }
  end

  describe '.limits' do
    subject { client.limits }

    it 'returns the limits for an organization' do
      limits = double('limits')
      limits.stub(:body).and_return({})
      client.should_receive(:api_get).with("limits").and_return(limits)
      client.should_receive(:options).and_return(api_version: 29.0)
      expect(client.limits).to eq({})
    end

    it "raises an exception if we aren't at version 29.0 or above" do
      client.should_receive(:options).at_least(:once).and_return(api_version: 24.0)
      expect { client.limits }.to raise_error(Restforce::APIVersionError)
    end
  end

  describe '.explain' do
    let(:soql)        { 'Select Id from Account' }
    subject(:results) { client.explain(soql) }

    it "returns an execute plan for this SOQL" do
      plans = double("plans")
      plans.stub(:body).and_return("plans" => [])
      client.should_receive(:api_get).with("query", explain: soql).
        and_return(plans)
      client.should_receive(:options).and_return(api_version: 30.0)
      expect(results).to eq("plans" => [])
    end

    it "raises an exception if we aren't at version 30.0 or above" do
      client.should_receive(:options).at_least(:once).and_return(api_version: 24.0)
      expect { results }.to raise_error(Restforce::APIVersionError)
    end
  end

  describe '.describe' do
    subject(:describe) { client.describe }

    it 'returns the global describe' do
      sobjects = double('sobjects')
      response.body.stub(:[]).with('sobjects').and_return(sobjects)
      client.should_receive(:api_get).
        with('sobjects').
        and_return(response)
      expect(describe).to eq sobjects
    end

    context 'when given the name of an sobject' do
      subject(:describe) { client.describe('Whizbang') }

      it 'returns the full describe' do
        client.should_receive(:api_get).
          with('sobjects/Whizbang/describe').
          and_return(response)
        expect(describe).to eq response.body
      end
    end
  end

  describe '.describe_layouts' do
    subject(:describe_layouts) { client.describe_layouts('Whizbang') }

    context "API version where describe_layouts is supported" do
      before { client.should_receive(:options).and_return(api_version: 28.0) }

      it 'returns the layouts for the sobject' do
        client.should_receive(:api_get).
          with('sobjects/Whizbang/describe/layouts').
          and_return(response)
        expect(describe_layouts).to eq response.body
      end

      context 'when given the id of a layout' do
        subject(:describe_layouts) do
          client.describe_layouts('Whizbang', '012E0000000RHEp')
        end

        it 'returns the describe for the specified layout' do
          client.should_receive(:api_get).
            with('sobjects/Whizbang/describe/layouts/012E0000000RHEp').
            and_return(response)
          expect(describe_layouts).to eq response.body
        end
      end
    end

    context "an API version where describe_layouts is not supported" do
      before { client.should_receive(:options).and_return(api_version: 24.0) }

      it "raises a error" do
        expect { describe_layouts }.to raise_error(Restforce::APIVersionError)
      end
    end
  end

  describe '.org_id' do
    subject(:org_id) { client.org_id }

    it 'returns the organization id' do
      organizations = [{ 'Id' => 'foo' }]
      client.should_receive(:query).
        with('select id from Organization').
        and_return(organizations)
      expect(org_id).to eq 'foo'
    end
  end

  describe '.query' do
    let(:soql)        { 'Select Id from Account' }
    subject(:results) { client.query(soql) }

    context 'with mashify middleware' do
      before do
        client.stub mashify?: true
      end

      it 'returns the body' do
        client.should_receive(:api_get).
          with('query', q: soql).
          and_return(response)
        expect(results).to eq response.body
      end
    end

    context 'without mashify middleware' do
      before do
        client.stub mashify?: false
      end

      it 'returns the records attribute of the body' do
        records = double('records')
        response.body.stub(:[]).
          with('records').
          and_return(records)
        client.should_receive(:api_get).
          with('query', q: soql).
          and_return(response)
        expect(results).to eq records
      end
    end
  end

  describe '.query_all' do
    let(:soql)        { 'Select Id from Account' }
    subject(:results) { client.query_all(soql) }

    context "with supported api_version" do
      before { client.should_receive(:options).and_return(api_version: 31.0) }

      context 'with mashify middleware' do
        before { client.stub(mashify?: true) }

        it 'returns the body' do
          client.should_receive(:api_get).with('queryAll', q: soql).
            and_return(response)
          expect(results).to eq(response.body)
        end
      end

      context 'without mashify middleware' do
        before do
          client.stub(mashify?: false)
        end

        it 'returns the records attribute of the body' do
          records = double('records')
          response.body.stub(:[]).with('records').and_return(records)
          client.should_receive(:api_get).with('queryAll', q: soql).
            and_return(response)
          expect(results).to eq(records)
        end
      end
    end

    context "with unsupported api_version" do
      before { client.should_receive(:options).and_return(api_version: 26.0) }

      subject(:query_all) { client.query_all(soql) }

      it "raises an error" do
        expect { query_all }.to raise_error(Restforce::APIVersionError)
      end
    end
  end

  describe '.search' do
    let(:sosl)        { 'FIND {bar}' }
    subject(:results) { client.search(sosl) }

    it 'performs a sosl search' do
      client.should_receive(:api_get).
        with('search', q: sosl).
        and_return(response)
      expect(results).to eq response.body
    end
  end

  %i[create update upsert destroy].each do |method|
    describe ".#{method}" do
      let(:args)       { [] }
      subject(:result) { client.send(method, *args) }

      it "delegates to :#{method}!" do
        client.should_receive(:"#{method}!").
          with(no_args).
          and_return(response)
        expect(result).to eq response
      end

      it 'rescues exceptions' do
        [Faraday::ClientError].each do |exception_klass|
          client.should_receive(:"#{method}!").
            with(no_args).
            and_raise(exception_klass.new(nil))
          expect(result).to eq false
        end
      end
    end
  end

  context 'methods with attrs' do
    before do
      attrs.freeze
    end

    describe '.create!' do
      let(:sobject)    { 'Whizbang' }
      let(:attrs)      { {} }
      subject(:result) { client.create!(sobject, attrs) }

      it 'send an HTTP POST, and returns the id of the record' do
        response.body.stub(:[]).with('id').and_return('1234')
        client.should_receive(:api_post).
          with('sobjects/Whizbang', attrs).
          and_return(response)
        expect(result).to eq '1234'
      end
    end

    describe '.update!' do
      let(:sobject)    { 'Whizbang' }
      let(:attrs)      { {} }
      subject(:result) { client.update!(sobject, attrs) }

      context 'when the id field is present' do
        let(:attrs) { { id: '1234', StageName: "Call Scheduled" } }

        it 'sends an HTTP PATCH, and returns true' do
          client.should_receive(:api_patch) do |*args|
            expect(args).to eq(["sobjects/Whizbang/1234",
                                { StageName: "Call Scheduled" }])
          end

          expect(result).to be true
        end
      end

      context 'when the id field contains special characters' do
        let(:attrs) { { id: '1234/?abc', StageName: "Call Scheduled" } }

        it 'sends an HTTP PATCH, and encodes the ID' do
          client.should_receive(:api_patch) do |*args|
            expect(args).to eq(['sobjects/Whizbang/1234%2F%3Fabc', {
                                 StageName: "Call Scheduled"
                               }])
          end

          expect(result).to be true
        end
      end

      context 'when the id field is missing from the attrs' do
        it "raises an error" do
          expect { client.update!(sobject, attrs) }.
            to raise_error(ArgumentError, 'ID field missing from provided attributes')
        end
      end
    end

    describe '.upsert!' do
      let(:sobject)    { 'Whizbang' }
      let(:field)      { :External_ID__c }
      let(:attrs)      { { 'External_ID__c' => '1234' } }
      subject(:result) { client.upsert!(sobject, field, attrs) }

      context 'when the record is found and updated' do
        it 'returns true' do
          response.stub(:body) { {} }
          client.should_receive(:api_patch).
            with('sobjects/Whizbang/External_ID__c/1234', {}).
            and_return(response)
          expect(result).to be true
        end

        context 'and the response body is a string' do
          it 'returns true' do
            response.stub(:body) { '' }
            client.should_receive(:api_patch).
              with('sobjects/Whizbang/External_ID__c/1234', {}).
              and_return(response)
            expect(result).to be true
          end
        end
      end

      context 'when the record is found and created' do
        it 'returns the id of the record' do
          response.stub(:body) { { "id" => "4321" } }
          client.should_receive(:api_patch).
            with('sobjects/Whizbang/External_ID__c/1234', {}).
            and_return(response)
          expect(result).to eq '4321'
        end
      end

      context 'when the external id field is missing from the attrs' do
        let(:attrs) { {} }

        it 'raises an argument error' do
          expect { client.upsert!(sobject, field, attrs) }.
            to raise_error ArgumentError, 'Specified external ID field missing from ' \
                                          'provided attributes'
        end
      end

      context 'when using Id as the attribute' do
        let(:field) { :Id }
        let(:attrs) { { 'Id' => '4321' } }

        context 'and the value for Id is provided' do
          it 'returns the id of the record, and original record still contains id' do
            response.stub(:body) { { "id" => "4321" } }
            client.should_receive(:api_patch).
              with('sobjects/Whizbang/Id/4321', {}).
              and_return(response)
            expect(result).to eq '4321'
            expect(attrs).to include('Id' => '4321')
          end
        end

        context 'and no value for Id is provided' do
          let(:attrs) { { 'External_ID__c' => '1234' } }

          it 'uses POST to create the record' do
            response.stub(:body) { { "id" => "4321" } }
            client.should_receive(:options).and_return(api_version: 38.0)
            client.should_receive(:api_post).
              with('sobjects/Whizbang/Id', attrs).
              and_return(response)
            expect(result).to eq '4321'
          end

          it 'guards functionality for unsupported API versions' do
            client.should_receive(:options).and_return(api_version: 35.0)
            expect do
              client.upsert!(sobject, field, attrs)
            end.to raise_error Restforce::APIVersionError
          end
        end
      end
    end

    describe '.upsert! with multi bytes character' do
      let(:sobject)    { 'Whizbang' }
      let(:field)      { :External_ID__c }
      let(:attrs)      { { 'External_ID__c' => "\u{3042}" } }
      subject(:result) { client.upsert!(sobject, field, attrs) }

      context 'when the record is found and updated' do
        it 'returns true' do
          response.stub(:body) { {} }
          client.should_receive(:api_patch).
            with('sobjects/Whizbang/External_ID__c/%E3%81%82', {}).
            and_return(response)
          expect(result).to be true
        end
      end
    end

    describe '.upsert! with Fixnum argument' do
      let(:sobject)    { 'Whizbang' }
      let(:field)      { :External_ID__c }
      let(:attrs)      { { 'External_ID__c' => 1234 } }
      subject(:result) { client.upsert!(sobject, field, attrs) }

      context 'when the record is found and updated' do
        it 'returns true' do
          response.stub(:body) { {} }
          client.should_receive(:api_patch).
            with('sobjects/Whizbang/External_ID__c/1234', {}).
            and_return(response)
          expect(result).to be true
        end
      end
    end
  end

  describe '.destroy!' do
    let(:id)         { '1234' }
    let(:sobject)    { 'Whizbang' }
    subject(:result) { client.destroy!(sobject, id) }

    it 'sends and HTTP delete, and returns true' do
      client.should_receive(:api_delete).
        with('sobjects/Whizbang/1234')
      expect(result).to be true
    end

    context 'when the id field contains special characters' do
      let(:id) { '1234/?abc' }

      it 'sends an HTTP delete, and encodes the ID' do
        client.should_receive(:api_delete).
          with('sobjects/Whizbang/1234%2F%3Fabc')
        expect(result).to be true
      end
    end
  end

  describe '.find' do
    let(:sobject)    { 'Whizbang' }
    let(:id)         { '1234' }
    let(:field)      { nil }
    subject(:result) { client.find(sobject, id, field) }

    context 'when no external id is specified' do
      it 'returns the full representation of the object' do
        client.should_receive(:api_get).
          with('sobjects/Whizbang/1234').
          and_return(response)
        expect(result).to eq response.body
      end
    end

    context 'when an external id is specified' do
      let(:field) { :External_ID__c }

      it 'returns the full representation of the object' do
        client.should_receive(:api_get).
          with('sobjects/Whizbang/External_ID__c/1234').
          and_return(response)
        expect(result).to eq response.body
      end
    end

    context 'when an external id which contains multibyte characters is specified' do
      let(:field) { :External_ID__c }
      let(:id)    { "\u{3042}" }
      it 'returns the full representation of the object' do
        client.should_receive(:api_get).
          with('sobjects/Whizbang/External_ID__c/%E3%81%82').
          and_return(response)
        expect(result).to eq response.body
      end
    end

    context 'when an internal ID which contains special characters is specified' do
      let(:id)    { "1234/?abc" }
      it 'returns the full representation of the object' do
        client.should_receive(:api_get).
          with('sobjects/Whizbang/1234%2F%3Fabc').
          and_return(response)
        expect(result).to eq response.body
      end
    end
  end

  describe '.select' do
    let(:sobject)    { 'Whizbang' }
    let(:id)         { '1234' }
    let(:field)      { nil }
    let(:select)     { nil }
    subject(:result) { client.select(sobject, id, select, field) }

    context 'when no external id is specified' do
      context 'when no select list is specified' do
        it 'returns the full representation of the object' do
          client.should_receive(:api_get).
            with('sobjects/Whizbang/1234').
            and_return(response)
          expect(result).to eq response.body
        end
      end
      context 'when select list is specified' do
        let(:select) { [:External_ID__c] }
        it 'returns the full representation of the object' do
          client.should_receive(:api_get).
            with('sobjects/Whizbang/1234?fields=External_ID__c').
            and_return(response)
          expect(result).to eq response.body
        end
      end
    end

    context 'when an external id is specified' do
      let(:field) { :External_ID__c }
      context 'when no select list is specified' do
        it 'returns the full representation of the object' do
          client.should_receive(:api_get).
            with('sobjects/Whizbang/External_ID__c/1234').
            and_return(response)
          expect(result).to eq response.body
        end
      end
      context 'when select list is specified' do
        let(:select) { [:External_ID__c] }
        it 'returns the full representation of the object' do
          client.should_receive(:api_get).
            with('sobjects/Whizbang/External_ID__c/1234?fields=External_ID__c').
            and_return(response)
          expect(result).to eq response.body
        end
      end
    end

    context 'when an external id which contains multibyte characters is specified' do
      let(:field) { :External_ID__c }
      let(:id) { "\u{3042}" }
      context 'when no select list is specified' do
        it 'returns the full representation of the object' do
          client.should_receive(:api_get).
            with('sobjects/Whizbang/External_ID__c/%E3%81%82').
            and_return(response)
          expect(result).to eq response.body
        end
      end
      context 'when select list is specified' do
        let(:select) { [:External_ID__c] }
        it 'returns the full representation of the object' do
          client.should_receive(:api_get).
            with('sobjects/Whizbang/External_ID__c/%E3%81%82?fields=External_ID__c').
            and_return(response)
          expect(result).to eq response.body
        end
      end
    end

    context 'when an internal ID which contains special characters is specified' do
      let(:id)    { "1234/?abc" }
      it 'returns the full representation of the object' do
        client.should_receive(:api_get).
          with('sobjects/Whizbang/1234%2F%3Fabc').
          and_return(response)
        expect(result).to eq response.body
      end
    end
  end

  describe "#recent" do
    let(:limit) { nil }
    subject(:result) { client.recent(limit) }

    context "given no limit is specified" do
      it "returns the most recently viewed items for the logged-in user" do
        client.should_receive(:api_get).with('recent').and_return(response)
        expect(result).to eq response.body
      end
    end

    context "given a limit is specified" do
      let(:limit) { 10 }

      it "returns up to the limit specified results" do
        client.should_receive(:api_get).with('recent?limit=10').and_return(response)
        expect(result).to eq response.body
      end
    end
  end
end
