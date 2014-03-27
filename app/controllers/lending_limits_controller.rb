class LendingLimitsController < ApplicationController
  include AuditableController

  before_filter :verify_create_permission, only: [:new, :create]
  before_filter :verify_update_permission, only: [:edit, :update, :activate, :deactivate]
  before_filter :verify_view_permission, only: [:index]
  before_filter :load_lender
  before_filter :load_phases, only: [:new, :edit]

  def index
    @lending_limits = @lender.lending_limits
  end

  def new
    @lending_limit = @lender.lending_limits.new
  end

  def create
    @lending_limit = @lender.lending_limits.new
    @lending_limit.attributes = params[:lending_limit]
    @lending_limit.active = true
    @lending_limit.modified_by = current_user

    save = -> { @lending_limit.save }

    if audit(AdminAudit::LendingLimitCreated, @lending_limit, &save)
      redirect_to lender_lending_limits_url(@lender)
    else
      load_phases
      render :new
    end
  end

  def edit
    @lending_limit = @lender.lending_limits.find(params[:id])
  end

  def update
    @lending_limit = @lender.lending_limits.find(params[:id])
    @lending_limit.attributes = params[:lending_limit].slice(:allocation, :name, :phase_id)
    @lending_limit.modified_by = current_user

    save = -> { @lending_limit.save }

    if audit(AdminAudit::LendingLimitEdited, @lending_limit, &save)
      redirect_to lender_lending_limits_url(@lender)
    else
      load_phases
      render :edit
    end
  end

  def activate
    @lending_limit = @lender.lending_limits.find(params[:id])
    @lending_limit.modified_by = current_user

    audit(AdminAudit::LendingLimitActivated, @lending_limit) do
      @lending_limit.activate!
    end

    redirect_to lender_lending_limits_url(@lender)
  end

  def deactivate
    @lending_limit = @lender.lending_limits.find(params[:id])
    @lending_limit.modified_by = current_user

    audit(AdminAudit::LendingLimitRemoved, @lending_limit) do
      @lending_limit.deactivate!
    end

    redirect_to lender_lending_limits_url(@lender)
  end

  private
    def load_lender
      @lender = Lender.find(params[:lender_id])
    end

    def load_phases
      @phases = Phase.all
    end

    def verify_create_permission
      enforce_create_permission(LendingLimit)
    end

    def verify_update_permission
      enforce_update_permission(LendingLimit)
    end

    def verify_view_permission
      enforce_view_permission(LendingLimit)
    end
end
