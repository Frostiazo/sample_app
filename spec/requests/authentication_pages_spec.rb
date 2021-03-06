require 'spec_helper'

describe 'Authentication' do

  subject { page }

  describe "signin page" do
    before { visit signin_path }

    let(:submit) { "Sign in" }

    it { should have_content('Sign in') }
    it { should have_title('Sign in') }

    describe "when user isn't signed in" do
      it { should_not have_link('Users') }
      it { should_not have_link('Settings') }
      it { should_not have_link('Profile') }
      it { should_not have_link('Sign out') }
    end

    describe "with invalid information" do
      before { click_button submit }

      it { should have_title("Sign in") }
      it { should have_error_message("Invalid") }

      describe "after visiting another page" do
        before { click_link "Home" }
        it { should_not have_selector('div.alert.alert-error') }
      end
    end

    describe "with valid information" do
      let (:user) { FactoryGirl.create(:user) }
      before { sign_in(user) }

      it { should have_title(user.name) }
      it { should have_link('Users',         href: users_path) }
      it { should have_link('Profile',        href: user_path(user)) }
      it { should have_link('Settings',       href: edit_user_path(user)) }
      it { should have_link('Sign out',       href: signout_path) }
      it { should_not have_link('Sign in',    href: signin_path) }

      describe "followed by signout" do
        before { click_link "Sign out" }
        it { should have_link("Sign in") }
      end
    end
  end

  # --- authorization ---

  describe "authorization" do

    describe "for non-signed-in users" do
      let (:user) { FactoryGirl.create:user }

      describe "when attempting to visit a protected page" do
        before do
          visit edit_user_path(user)
          fill_sign_in_form user
        end

        describe "after signing in" do

          it "should render the desired protected page" do
            expect(page).to have_title('Edit user')
          end

          describe "after signing in again" do
            before do
              delete signout_path
              visit signin_path
              fill_sign_in_form user
            end

            it "should render the default (profile) page" do
              expect(page).to have_title(user.name)
            end
          end
        end
      end


      describe "in the Users controller" do

        describe "visiting the edit page" do
          before { visit edit_user_path(user) }
          it { should have_title('Sign in') }
        end

        describe "submitting to the update action" do
          before { patch user_path(user) }
          specify { expect(response).to redirect_to(signin_path) }
        end

        describe "visiting the user index" do
          before { visit users_path }
          it { should have_title('Sign in') }
        end
      end


      describe "in the microposts controller" do

        describe "submitting to the CREATE action" do
          before { post microposts_path }
          specify { expect(response).to redirect_to(signin_path) }
        end

        describe "submitting to the DESTROY action" do
          let(:micropost) { FactoryGirl.create(:micropost) }
          before { delete micropost_path(:micropost) }
          specify { expect(response).to redirect_to(signin_path) }
        end
      end

    end


    describe "as wrong user" do

      let(:user) { FactoryGirl.create(:user) }
      let(:wrong_user) { FactoryGirl.create(:user, email: "wrong@example.com") }
      before { sign_in user, not_capybara: true }

      describe "submitting a GET request to the Users#edit action" do
        before { get edit_user_path(wrong_user) }
        specify { expect(response.body).not_to match(full_title('Edit user')) }
        specify { expect(response).to redirect_to(root_url) }
      end

      describe "submitting a PATCH request to the Users#update action" do
        before { patch user_path(wrong_user) }
        specify { expect(response).to redirect_to(root_url) }
      end
    end


    describe "as non-admin user" do
      let(:user) { FactoryGirl.create(:user) }
      let(:non_admin) { FactoryGirl.create(:user) }

      before { sign_in(non_admin, not_capybara: true) }

      describe "submitting a DELETE request to the Users#destroy action" do
        before { delete user_path(user) }
        specify { expect(response).to redirect_to(root_url) }
      end
    end


    describe "as admin user" do
      let(:admin) { FactoryGirl.create(:admin) }
      before { sign_in(admin, not_capybara: true) }

      it "should not be able to delete himself using Users#destroy" do
        expect { delete user_path(admin) }.not_to change(User, :count)
      end
    end

    describe "all users" do
      let(:user) { FactoryGirl.create(:user) }
      before { sign_in(user, not_capybara: :true) }

      describe "microposts delete links" do
        let(:other_user) { FactoryGirl.create(:user) }
        let!(:other_m) { FactoryGirl.create(:micropost, user: other_user) }
        let!(:user_m) { FactoryGirl.create(:micropost, user: user) }

        it "can't be seen for other user's microposts" do
          visit user_path(other_user)
          page.should_not have_link('delete', href: micropost_path(other_m))
        end

      end

    end

  end

end

