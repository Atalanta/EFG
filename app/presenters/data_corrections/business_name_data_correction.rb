class BusinessNameDataCorrection < DataCorrectionPresenter
  attr_accessor :business_name
  attr_accessible :business_name

  before_save :update_data_correction
  before_save :update_loan

  validates :business_name, presence: true

  private
    def update_data_correction
      data_correction.change_type = ChangeType::BusinessName
      data_correction.business_name = business_name
      data_correction.old_business_name = loan.business_name
    end

    def update_loan
      loan.business_name = business_name
    end
end
