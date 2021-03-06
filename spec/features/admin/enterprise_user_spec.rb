require "spec_helper"

feature '
    As a Super User
    I want to setup users to manage an enterprise
' do
  include AuthenticationWorkflow
  include WebHelper

  let!(:user) { create_enterprise_user }
  let!(:supplier1) { create(:supplier_enterprise, name: 'Supplier 1') }
  let!(:supplier2) { create(:supplier_enterprise, name: 'Supplier 2') }
  let(:supplier_profile) { create(:supplier_enterprise, name: 'Supplier profile', sells: 'none') }
  let!(:distributor1) { create(:distributor_enterprise, name: 'Distributor 3') }
  let!(:distributor2) { create(:distributor_enterprise, name: 'Distributor 4') }
  let(:distributor_profile) { create(:distributor_enterprise, name: 'Distributor profile', sells: 'none') }

  describe "creating an enterprise user" do
    context "with a limitted number of owned enterprises" do
      scenario "setting the enterprise ownership limit" do
        expect(user.enterprise_limit).to eq 5
        login_to_admin_section
        click_link 'Users'
        click_link user.email

        fill_in "user_enterprise_limit", with: 2

        click_button 'Update'
        user.reload
        expect(user.enterprise_limit).to eq 2
      end
    end
  end

  describe "system management lockdown" do
    before do
      user.enterprise_roles.create!(enterprise: supplier1)
      quick_login_as user
    end

    scenario "should not be able to see system configuration" do
      visit spree.edit_admin_general_settings_path
      expect(page).to have_content 'Unauthorized'
    end

    scenario "should not be able to see user management" do
      visit spree.admin_users_path
      expect(page).to have_content 'Unauthorized'
    end
  end
end
