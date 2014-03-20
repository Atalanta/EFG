class AuditorUser < User
  include AuditorUserPermissions

  def lender
    AuditorUserLender.new
  end

  def lenders
    Lender.all
  end

  def lender_ids
    lenders.pluck(:id)
  end
end
