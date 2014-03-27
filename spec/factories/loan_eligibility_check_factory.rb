FactoryGirl.define do
  factory :loan_eligibility_check do
    viable_proposition 'true'
    would_you_lend 'true'
    collateral_exhausted 'true'
    not_insolvent 'true'
    amount '12345'
    repayment_duration({ years: '1', months: '6' })
    turnover '12345'
    trading_date '31/1/2011'
    sic_code { FactoryGirl.create(:sic_code).code }
    loan_category_id '1'
    previous_borrowing 'true'
    private_residence_charge_required 'false'
    personal_guarantee_required 'true'
    loan_scheme 'E'
    loan_source 'S'

    initialize_with {
      loan = FactoryGirl.build(:loan)
      loan.state = nil
      new(loan)
    }

    after :build do |loan_eligibility_check|
      loan_eligibility_check.lending_limit_id ||= begin
        lender = loan_eligibility_check.loan.lender
        FactoryGirl.build(:lending_limit, lender: lender)
      end
    end
  end
end
