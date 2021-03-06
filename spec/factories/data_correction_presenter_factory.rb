FactoryGirl.define do
  factory :data_correction_presenter do
    ignore do
      association :loan, factory: [:loan, :guaranteed]
      association :created_by, factory: :lender_user
    end

    initialize_with do
      new(loan, created_by)
    end

    factory :business_name_data_correction, class: BusinessNameDataCorrection do
      business_name 'New Business Name'
    end

    factory :demanded_amount_data_correction, class: DemandedAmountDataCorrection do
      demanded_amount Money.new(1_000_00)
      association :loan, factory: [:loan, :guaranteed, :demanded]
    end

    factory :lender_reference_data_correction, class: LenderReferenceDataCorrection do
      lender_reference 'New Lender Reference'
    end

    factory :postcode_data_correction, class: PostcodeDataCorrection do
      postcode 'EC1A 9PN'
    end

    factory :sortcode_data_correction, class: SortcodeDataCorrection do
      sortcode '123456'
    end
  end
end
