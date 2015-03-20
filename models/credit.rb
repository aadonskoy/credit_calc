class Credit
  attr_reader :error_messages, :payments, :percent, :amount, :term

  def initialize(options = {})
    @percent = options.fetch('percent').to_f
    @amount = options.fetch('amount').to_f
    @cred_meth = options.fetch('cred_meth').to_i
    @term = options.fetch('term').to_i
    @payments = []
    @error_messages = []
  end

  def valid?
    validate
    @error_messages.length == 0
  end

  def validate
    @error_messages = []
    @error_messages << 'Процентная ставка должна быть больше 0.' if @percent <= 0
    @error_messages << 'Сумма кредита должна быть больше 0.' if @amount <= 0
    @error_messages << 'Передано неверное значение метода погашения кредита' unless [1, 2].include?(@cred_meth)
    @error_messages << 'Срок должен быть более 1 месяца' if @term <= 0
    @error_messages
  end

  def calculate
    return if validate.length > 0
    return @payments if @payments.length > 0
    differencial if @cred_meth == 1
    annuit if @cred_meth == 2
    @payments
  end

  def cred_meth
    case @cred_meth
    when 1
      'Стандартный'
    when 2
      'Аннуитентный (равными частями)'
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
