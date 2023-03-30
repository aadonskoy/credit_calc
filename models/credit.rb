# frozen_string_literal: true

class Credit
  include ActiveModel::Validations

  attr_reader :payments, :percent, :amount, :term, :cred_meth

  validates :percent, :amount, :term, presence: true
  validates :percent, :amount, :term,
            numericality: { greater_than: 0 }
  validates_inclusion_of :cred_meth,
                         in: [1, 2],
                         message: 'Incorrect credit method'

  def initialize(options = {})
    @percent = options.fetch('percent').to_f
    @amount = options.fetch('amount').to_f
    @cred_meth = options.fetch('cred_meth').to_i
    @term = options.fetch('term').to_i
    @payments = []
  end

  def calculate
    return if invalid?
    return payments if payments.length.positive?

    differencial if cred_meth == 1
    annuit if cred_meth == 2
    payments
  end

  def cred_meth_name
    case cred_meth
    when 1
      'Standard (differencial)'
    when 2
      'Annuity (Equal payments)'
    else
      ''
    end
  end

  private

  def differencial
    @term.times do |month|
      payment = main_payment + period_percent(month)
      leftover = @amount - main_payment * (month + 1)
      @payments << { amount: floor_dec(main_payment),
                     percent: floor_dec(period_percent(month)),
                     payment: floor_dec(payment),
                     leftover: floor_dec(leftover)}
    end
  end

  def annuit
    payment = @amount * (yearly_percent + yearly_percent / ((1 + yearly_percent)**@term - 1))
    leftover = @amount
    @term.times do |month|
      percent = leftover * yearly_percent
      main_credit = payment - percent
      leftover -= main_credit
      @payments << { amount: floor_dec(main_credit),
                     percent: floor_dec(percent),
                     payment: floor_dec(payment),
                     leftover: floor_dec(leftover)}
    end
  end

  def period_percent(month)
    (@amount - main_payment * month) * yearly_percent
  end

  def yearly_percent
    (@percent / 100) / 12
  end

  def main_payment
    @amount / @term
  end

  def floor_dec(num)
    (num * 100).ceil / 100.0
  end
end
