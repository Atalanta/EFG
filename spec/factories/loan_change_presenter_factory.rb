FactoryGirl.define do
  factory :loan_change_presenter do
    ignore do
      association :loan, factory: [:loan, :guaranteed]
      association :created_by, factory: :lender_user
    end

    date_of_change Date.new
    initial_draw_amount Money.new(10_000_00)

    initialize_with do
      new(loan, created_by)
    end

    factory :lump_sum_repayment_loan_change, class: LumpSumRepaymentLoanChange do
      lump_sum_repayment Money.new(1_000_00)
    end

    factory :repayment_duration_loan_change, class: RepaymentDurationLoanChange do
      added_months 3
    end

    factory :reprofile_draws_loan_change, class: ReprofileDrawsLoanChange
  end
end