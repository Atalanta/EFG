class LoanCancelsController < ApplicationController
  before_filter :verify_create_permission, only: [:new, :create]
  rescue_from_incorrect_loan_state_error

  def new
    @loan = current_lender.loans.find(params[:loan_id])
    @loan_cancel = LoanCancel.new(@loan)
  end

  def create
    @loan = current_lender.loans.find(params[:loan_id])
    @loan_cancel = LoanCancel.new(@loan)
    @loan_cancel.attributes = params[:loan_cancel]
    @loan_cancel.modified_by = current_user

    if @loan_cancel.save
      redirect_to loan_url(@loan)
    else
      render :new
    end
  end

  private
  def verify_create_permission
    enforce_create_permission(LoanCancel)
  end
end
