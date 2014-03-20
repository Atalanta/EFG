class CfeAdminLender
  def users
    CfeAdmin.all
  end

  def can_access_all_loan_schemes?
    true
  end
end
