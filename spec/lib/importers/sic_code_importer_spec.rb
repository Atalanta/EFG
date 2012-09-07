require 'spec_helper'
require 'importers'

describe SicCodeImporter do

  let(:csv_fixture_path) { Rails.root.join('spec/fixtures/import_data/SIC_2007_DATA.csv') }

  describe ".import" do
    def dispatch
      SicCodeImporter.csv_path = csv_fixture_path
      SicCodeImporter.import
    end

    it "should create new records" do
      expect {
        dispatch
      }.to change(SicCode, :count).by(3)
    end

    it "should import data correctly" do
      dispatch

      sic_code1 = SicCode.first
      sic_code1.code.should == "01110"
      sic_code1.description.should == "Growing of cereals (except rice), leguminous crops and oil seeds"
      sic_code1.should be_eligible
      sic_code1.should_not be_public_sector_restricted

      sic_code2 = SicCode.first(2).last
      sic_code2.code.should == "64110"
      sic_code2.description.should == "Central banking"
      sic_code2.should_not be_eligible
      sic_code2.should_not be_public_sector_restricted

      sic_code3 = SicCode.last
      sic_code3.code.should == "81100"
      sic_code3.description.should == "Combined facilities support activities"
      sic_code3.should be_eligible
      sic_code3.should be_public_sector_restricted
    end
  end

end
