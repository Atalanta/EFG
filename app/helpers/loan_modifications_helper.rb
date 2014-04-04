module LoanModificationsHelper
  def format_modification_value(value)
    case value
    when Date
      value.to_s(:screen)
    when LendingLimit
      value.name
    when Money
      value.format
    when RepaymentFrequency
      value.name
    else
      value
    end
  end
end
