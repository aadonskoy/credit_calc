require 'spec_helper'

RSpec.describe App do
  def app
    App
  end

  describe 'GET root' do
    it 'status is 200' do
      get '/'
      expect(last_response.status).to eq(200)
    end
  end

  describe 'POST data' do
    before(:each) { post_query }
    let(:post_query) { post '/payments', parameters }

    context 'produce error' do
      let(:parameters) { { percent: '0', amount: '100.0', cred_meth: '1', term: '0' } }
      it 'response status 400' do
        expect(last_response.status).to eq(400)
      end

      it 'show alerts' do
        expect(last_response.body).to include('alert-danger')
      end
    end

    context 'produce ok' do
      let(:parameters) { { percent: '10', amount: '100.0', cred_meth: '1', term: '6' } }
      it 'response status ok' do
        expect(last_response.status).to eq(200)
      end

      it 'show table with 6 payments' do
        expect(last_response.body.scan("<th scope='row'>").length).to eq(6)
      end
    end
  end
end
