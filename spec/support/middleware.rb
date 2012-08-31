shared_examples_for 'authentication middleware' do
  describe '.authenticate!' do
    after do
      request.should have_been_requested
    end

    context 'when successful' do
      let!(:request) { success_request }

      before do
        middleware.authenticate!
      end

      describe '@options' do
        subject { options }

        its([:instance_url]) { should eq 'https://na1.salesforce.com' }
        its([:oauth_token])  { should eq '00Dx0000000BV7z!AR8AQAxo9UfVkh8AlV0Gomt9Czx9LjHnSSpwBMmbRcgKFmxOtvxjTrKW19ye6PE3Ds1eQz3z8jr3W7_VbWmEu4Q8TVGSTHxs' }
      end
    end

    context 'when unsuccessful' do
      let!(:request) { fail_request }

      it 'raises an exception' do
        expect {
          middleware.authenticate!
        }.to raise_error Restforce::AuthenticationError
      end
    end

  end
end
