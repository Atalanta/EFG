require 'spec_helper'

describe RealisationStatement do
  let(:realisation_statement) { FactoryGirl.build(:realisation_statement) }

  describe "validations" do

    it 'should have a valid factory' do
      realisation_statement.should be_valid
    end

    it 'must have a lender' do
      realisation_statement.lender = nil
      realisation_statement.should_not be_valid
    end

    it 'must have a created by user' do
      realisation_statement.created_by = nil
      realisation_statement.should_not be_valid
    end

    it 'must have a reference' do
      realisation_statement.reference = nil
      realisation_statement.should_not be_valid
    end

    it 'must have a period recovery quarter' do
      realisation_statement.period_covered_quarter = nil
      realisation_statement.should_not be_valid
    end

    it 'must have a valid period recovery quarter' do
      realisation_statement.period_covered_quarter = 'April'
      realisation_statement.should_not be_valid
    end

    it 'must have a period covered year' do
      realisation_statement.period_covered_year = nil
      realisation_statement.should_not be_valid
    end

    it 'must have a valid period covered year' do
      realisation_statement.period_covered_year = '201'
      realisation_statement.should_not be_valid
    end

    it 'must have a received on date' do
      realisation_statement.received_on = nil
      realisation_statement.should_not be_valid
    end

    it 'must have a valid received on date' do
      realisation_statement.received_on = '2012-05-01'
      realisation_statement.should_not be_valid
    end

    it "must have loans to be realised" do
      realisation_statement.recoveries_to_be_realised_ids = []
      realisation_statement.should_not be_valid
    end

  end

  describe "#recoveries" do
    let(:loan) { FactoryGirl.create(:loan, lender: realisation_statement.lender, settled_on: Date.new(2010)) }

    let!(:specified_quarter_recovery) { FactoryGirl.create(:recovery, loan: loan, recovered_on: Date.new(2012, 3, 31)) }
    let!(:previous_quarter_recovery)  { FactoryGirl.create(:recovery, loan: loan, recovered_on: Date.new(2011, 12, 31)) }
    let!(:next_quarter_recovery)      { FactoryGirl.create(:recovery, loan: loan, recovered_on: Date.new(2012, 6, 30)) }

    before do
      realisation_statement.period_covered_quarter = 'March'
      realisation_statement.period_covered_year = '2012'
    end

    it "should return recoveries within or prior to the specified quarter" do
      recoveries = realisation_statement.recoveries

      recoveries.size.should == 2
      recoveries.should include(specified_quarter_recovery)
      recoveries.should include(previous_quarter_recovery)
    end

    it 'does not include recoveries from other lenders' do
      other_lender_recovery = FactoryGirl.create(:recovery, recovered_on: Date.new(2012))

      realisation_statement.recoveries.should_not include(other_lender_recovery)
    end

    it 'does not include already realised recoveries' do
      already_recovered_recovery = FactoryGirl.create(:recovery, loan: loan, realise_flag: true)

      realisation_statement.recoveries.should_not include(already_recovered_recovery)
    end
  end

  describe '#recoveries_to_be_realised_ids' do
    let(:lender) { FactoryGirl.create(:lender) }
    let(:loan1) { FactoryGirl.create(:loan, :recovered, lender: lender, settled_on: Date.new(2000)) }
    let(:recovery1) { FactoryGirl.create(:recovery, loan: loan1) }

    before do
      realisation_statement.lender = lender
    end

    context 'with already realised recoveries' do
      let(:recovery2) { FactoryGirl.create(:recovery, realise_flag: true, loan: loan1) }

      it 'does not assign them' do
        realisation_statement.recoveries_to_be_realised_ids = [recovery1.id, recovery2.id]
        realisation_statement.recoveries_to_be_realised.should include(recovery1)
        realisation_statement.recoveries_to_be_realised.should_not include(recovery2)
      end
    end

    context 'with recoveries from other lenders' do
      let(:recovery2) { FactoryGirl.create(:recovery) }

      it 'does not assign them' do
        realisation_statement.recoveries_to_be_realised_ids = [recovery1.id, recovery2.id]
        realisation_statement.recoveries_to_be_realised.should include(recovery1)
        realisation_statement.recoveries_to_be_realised.should_not include(recovery2)
      end
    end
  end

  describe "#save_and_realise_loans" do
    let(:lender) { FactoryGirl.create(:lender) }

    context 'with valid loans to be realised' do
      let(:loan1) { FactoryGirl.create(:loan, :recovered, lender: lender, settled_on: Date.new(2000)) }
      let(:loan2) { FactoryGirl.create(:loan, :recovered, lender: lender, settled_on: Date.new(2000)) }
      let(:recovery1) { FactoryGirl.create(:recovery, loan: loan1, amount_due_to_dti: Money.new(123_00)) }
      let(:recovery2) { FactoryGirl.create(:recovery, loan: loan2, amount_due_to_dti: Money.new(456_00)) }
      let(:recovery3) { FactoryGirl.create(:recovery, loan: loan2, amount_due_to_dti: Money.new(789_00)) }

      before(:each) do
        realisation_statement.lender = lender
        realisation_statement.recoveries_to_be_realised_ids = [recovery1.id, recovery2.id, recovery3.id]
        realisation_statement.save_and_realise_loans
      end

      it 'updates all loans to be realised to Realised state' do
        loan1.reload.state.should == Loan::Realised
        loan2.reload.state.should == Loan::Realised
      end

      it 'updates recoveries to be realised' do
        recovery1.reload.realise_flag.should be_true
        recovery2.reload.realise_flag.should be_true
        recovery3.reload.realise_flag.should be_true
      end

      it 'creates loan realisation for each loan to be realised' do
        LoanRealisation.count.should == 2
      end

      it 'creates loan realisations with the same created by user as the realisation statement' do
        realisation_statement.loan_realisations.each do |loan_realisation|
          loan_realisation.created_by.should == realisation_statement.created_by
        end
      end

      it 'stores the realised amount on each new loan realisation' do
        realisation_statement.loan_realisations.find_by_realised_loan_id!(loan1.id).realised_amount.should == Money.new(123_00)
        realisation_statement.loan_realisations.find_by_realised_loan_id!(loan2.id).realised_amount.should == Money.new(1245_00)
      end

      it 'associates the recoveries with the realisation statement' do
        recovery1.reload.realisation_statement.should == realisation_statement
        recovery2.reload.realisation_statement.should == realisation_statement
        recovery3.reload.realisation_statement.should == realisation_statement
      end
    end
  end
end