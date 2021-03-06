# encoding: utf-8

require 'spec_helper'

describe LoanTypeGroupSet do
  describe LoanTypeGroupSet::Group do
    describe ".for" do
      it "returns a Group subclass with a method defined for the objects name" do
        group = LoanTypeGroupSet::Group.for(:loans).new('SFLG Loans')
        group.should respond_to(:loans)
      end
    end

    describe ".new" do
      it "initializes with a name" do
        group = LoanTypeGroupSet::Group.new('Legacy SFLG Loans')
        group.name.should == 'Legacy SFLG Loans'
      end
    end

    describe "<<" do
      let(:group) { LoanTypeGroupSet::Group.for(:recoveries).new('EFG Loans') }

      it "adds the the defined objects method" do
        recovery = double('Recovery')
        group << recovery
        group.recoveries.should == [recovery]
      end
    end
  end

  describe ".filter" do
    let(:lending_limit) { double('LendingLimit', phase_id: 1)}
    let(:legacy_loan_1) { double(:legacy_loan? => true, :sflg? => false, :efg_loan? => false)}
    let(:legacy_loan_2) { double(:legacy_loan? => true, :sflg? => false, :efg_loan? => false)}
    let(:sflg_loan_1) { double(:legacy_loan? => false, :sflg? => true, :efg_loan? => false)}
    let(:sflg_loan_2) { double(:legacy_loan? => false, :sflg? => true, :efg_loan? => false)}
    let(:efg_loan_1) { double(:legacy_loan? => false, :sflg? => false, :efg_loan? => true, :lending_limit => lending_limit)}
    let(:efg_loan_2) { double(:legacy_loan? => false, :sflg? => false, :efg_loan? => true, :lending_limit => lending_limit)}

    let(:loans) { [legacy_loan_1, legacy_loan_2, sflg_loan_1, sflg_loan_2, efg_loan_1, efg_loan_2] }
    let(:set) { LoanTypeGroupSet.filter(:loans, loans) }

    it "returns the correct groups" do
      expected_group_names = ['Legacy SFLG Loans', 'SFLG Loans']
      expected_group_names.concat Phase.all.map { |phase| "EFG Loans – #{phase.name}" }
      expected_group_names << 'EFG Loans – Unknown Phase'

      group_names = set.groups.map(&:name).to_a
      group_names.should == expected_group_names
    end

    it "returns groups that respond to the objects name" do
      set.groups.each do |group|
        group.should respond_to(:loans)
      end
    end

    context "without a mapper" do
      it "filters the objects into the appropriate groups" do
        groups = set.to_a
        groups[0].loans.should =~ [legacy_loan_1, legacy_loan_2]
        groups[1].loans.should =~ [sflg_loan_1, sflg_loan_2]
        groups[2].loans.should =~ [efg_loan_1, efg_loan_2]
      end
    end

    context "with a mapper" do
      let(:legacy_recovery_1) { double(loan: legacy_loan_1) }
      let(:legacy_recovery_2) { double(loan: legacy_loan_2) }
      let(:sflg_recovery_1) { double(loan: sflg_loan_1) }
      let(:sflg_recovery_2) { double(loan: sflg_loan_2) }
      let(:efg_recovery_1) { double(loan: efg_loan_1) }
      let(:efg_recovery_2) { double(loan: efg_loan_2) }

      let(:recoveries) { [legacy_recovery_1, legacy_recovery_2, sflg_recovery_1, sflg_recovery_2, efg_recovery_1, efg_recovery_2]}
      let(:set) { LoanTypeGroupSet.filter(:recoveries, recoveries) {|recovery| recovery.loan } }

      it "filters the objects into the groups, using the mapper to determine the loan" do
        groups = set.to_a
        groups[0].recoveries.should =~ [legacy_recovery_1, legacy_recovery_2]
        groups[1].recoveries.should =~ [sflg_recovery_1, sflg_recovery_2]
        groups[2].recoveries.should =~ [efg_recovery_1, efg_recovery_2]
      end
    end
  end
end
