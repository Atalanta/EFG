class LoanAuditLog

  attr_reader :loan_state_change, :previous_state_change

  def initialize(loan_state_change, previous_state_change = nil)
    @loan_state_change = loan_state_change
    @previous_state_change = previous_state_change
  end

  # event ID 0 == 'Accept', 1 == 'Reject'
  def event_name
    [0, 1].include?(loan_state_change.event_id) ? 'Check Eligibility' : loan_state_change.event.name
  end

  # The initial from state for a loan will always be 'Created'
  def from_state
    previous_state_change.present? ? previous_state_change.state.humanize : 'Created'
  end

  def to_state
    loan_state_change.state.humanize
  end

  def modified_on
    loan_state_change.modified_on.strftime("%d/%m/%Y")
  end

  def modified_by
    loan_state_change.modified_by.name
  end

end
