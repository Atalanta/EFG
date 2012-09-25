require 'spec_helper'

describe "User audit" do

  let(:current_user) { FactoryGirl.create(:lender_user) }

  it "should create new audit record when user first signs in" do
    visit root_path

    fill_in "user_username", with: current_user.username
    fill_in "user_password", with: current_user.password

    expect {
      click_button "Sign In"
    }.to change(current_user.user_audits, :count).by(1)

    current_user.reload
    user_audit = current_user.user_audits.last
    user_audit.function.should == UserAudit::INITIAL_LOGIN
    user_audit.modified_by.should == current_user
    user_audit.password.should == current_user.encrypted_password

    # subsequent login should not create user audit record
    click_link "Logout"
    fill_in "user_username", with: current_user.username
    fill_in "user_password", with: current_user.password

    expect {
      click_button "Sign In"
    }.to_not change(current_user.user_audits, :count)
  end

  it "should create new audit record when user changes their password" do
    current_user = FactoryGirl.create(:lender_user)
    login_as(current_user, scope: :user)

    visit edit_change_password_path
    click_link 'Change Password'

    fill_in "lender_user_password", with: 'new-password'
    fill_in "lender_user_password_confirmation", with: 'new-password'

    expect {
      click_button 'Update Password'
    }.to change(current_user.user_audits, :count).by(1)

    current_user.reload
    user_audit = current_user.user_audits.last
    user_audit.function.should == UserAudit::PASSWORD_CHANGED
    user_audit.modified_by.should == current_user
    user_audit.password.should == current_user.encrypted_password
  end

  it "should create new audit record when user first sets their password" do
    current_user = FactoryGirl.create(
      :lender_user,
      encrypted_password: nil,
      reset_password_token: 'abc123',
      reset_password_sent_at: 1.minute.ago
    )

    visit edit_user_password_path(current_user, :reset_password_token => current_user.reset_password_token)
    fill_in "user_password", with: 'password'
    fill_in "user_password_confirmation", with: 'password'

    expect {
      click_button 'Change Password'
    }.to change(current_user.user_audits, :count).by(1)

    current_user.reload
    user_audit2 = current_user.user_audits.last
    user_audit2.function.should == UserAudit::INITIAL_LOGIN
    user_audit2.modified_by.should == current_user
    user_audit2.password.should == current_user.encrypted_password

    # resetting password again should not create user audit record

    click_link "Logout"
    current_user.reset_password_token = 'def456'
    current_user.reset_password_sent_at = 1.minute.ago
    current_user.save

    visit edit_user_password_path(current_user, :reset_password_token => current_user.reset_password_token)
    fill_in "user_password", with: 'new-password'
    fill_in "user_password_confirmation", with: 'new-password'

    expect {
      click_button 'Change Password'
    }.to_not change(current_user.user_audits, :count)
  end

end