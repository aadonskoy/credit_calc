require 'spec_helper'

RSpec.describe Credit do
  describe 'data missing' do
    let(:no_amount)    { { 'percent' => 10, 'term' => 10, 'cred_meth' => 1 } }
    let(:no_percent)   { { 'amount' => 100_000, 'term' => 10, 'cred_meth' => 1 } }
    let(:no_term)      { { 'amount' => 100_000, 'percent' => 10, 'cred_meth' => 1 } }
    let(:no_cred_meth) { { 'amount' => 100_000, 'percent' => 10, 'term' => 6 } }

    it { expect { Credit.new(no_amount)}.to raise_error }
    it { expect { Credit.new(no_percent)}.to raise_error }
    it { expect { Credit.new(no_term)}.to raise_error }
    it { expect { Credit.new(no_cred_meth)}.to raise_error }
  end

  describe 'validation' do
    let(:wrong_amount)    { { 'amount' => '-23', 'percent' => 10, 'term' => 10, 'cred_meth' => 1  } }
    let(:wrong_percent)   { { 'amount' => 100_000, 'percent' =>  0, 'term' => 10, 'cred_meth' => 1  } }
    let(:wrong_term)      { { 'amount' => 100_000, 'percent' => 10, 'term' => 0,  'cred_meth' => 1  } }
    let(:wrong_cred_meth) { { 'amount' => 100_000, 'percent' => 10, 'term' => 6,  'cred_meth' => 43 } }
    let(:correct_data)    { { 'amount' => 100_000, 'percent' => 10, 'term' => 6,  'cred_meth' => 1 } }

    context 'valid data' do
      it { expect(Credit.new(correct_data).valid?).to be(true) }
      it { expect(Credit.new(correct_data).errors).to be_empty }
    end

    context 'not valid data' do
      it { expect(Credit.new(wrong_amount).valid?).to eq(false) }
      it { expect(Credit.new(wrong_percent).valid?).to eq(false) }
      it { expect(Credit.new(wrong_term).valid?).to eq(false) }
      it { expect(Credit.new(wrong_cred_meth).valid?).to be(false) }
    end
  end

  describe 'good data' do
    let(:data_default) { { 'amount' => 100_000, 'percent' => 10, 'term' => 6,  'cred_meth' => 1 } }
    let(:data_annuitent) { { 'amount' => 100_000, 'percent' => 10, 'term' => 6,  'cred_meth' => 2 } }

    context 'attributes' do
      it { expect(Credit.new(data_default).cred_meth_name).to include('Standard')}
      it { expect(Credit.new(data_annuitent).cred_meth_name).to include('Annuity')}
      it { expect(Credit.new(data_default).amount).to eq(data_default['amount']) }
      it { expect(Credit.new(data_default).percent).to eq(data_default['percent']) }
      it { expect(Credit.new(data_default).term).to eq(data_default['term']) }
    end

    context(:calc_standart) do
      subject(:payments) { credit = Credit.new(data_default).calculate }
      it { expect(payments.length).to eq(6) }
      it { expect(payments[5][:amount]).to eq(16666.67) }
      it { expect(payments[5][:percent]).to eq(138.89) }
      it { expect(payments[5][:payment]).to eq(16805.56) }
      it { expect(payments[5][:leftover]).to eq(0) }
    end

    context(:calc_annuitent) do
      subject(:payments) { credit = Credit.new(data_annuitent).calculate }
      it { expect(payments.length).to eq(6) }
      it { expect(payments[5][:amount]).to eq(17014.36) }
      it { expect(payments[5][:percent]).to eq(141.79) }
      it { expect(payments[5][:payment]).to eq(17156.14) }
      it { expect(payments[5][:leftover]).to eq(0) }
    end
  end
end
