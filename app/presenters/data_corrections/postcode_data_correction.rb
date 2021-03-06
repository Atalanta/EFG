class PostcodeDataCorrection < DataCorrectionPresenter
  include PresenterFormatterConcern

  format :postcode, with: PostcodeFormatter

  attr_accessible :postcode

  before_save :update_data_correction
  before_save :update_loan

  validate :validate_postcode

  private
    def update_data_correction
      data_correction.change_type = ChangeType::Postcode
      data_correction.postcode = postcode
      data_correction.old_postcode = loan.postcode
    end

    def update_loan
      loan.postcode = postcode
    end

    def validate_postcode
      errors.add(:postcode, :invalid) unless postcode.full?
    end
end
