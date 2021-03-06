shared_examples_for 'rescue_from LoanStateTransition::IncorrectLoanState controller' do
  let(:current_user) { FactoryGirl.create(:lender_user, lender: loan.lender) }

  before do
    loan.update_attribute :state, 'incorrect state'
    sign_in(current_user)
  end

  it "should redirect to the loan" do
    dispatch
    response.should redirect_to(loan_path(loan))
  end
end
