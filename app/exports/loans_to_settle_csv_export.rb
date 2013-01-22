class LoansToSettleCsvExport < BaseCsvExport

  private

  def fields
    [
      :reference,
      :business_name,
      :dti_demanded_on,
      :dti_amount_claimed,
    ]
  end

end