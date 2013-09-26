include ApplicationHelper

def sign_in(user, options={})
  if options[:not_capybara]
    # Sign in when not using capybara
    remember_token = User.new_remember_token
    cookies[:remember_token] = remember_token
    user.update_attribute :remember_token, User.encrypt(remember_token)
  else
    visit signin_path
    fill_sign_in_form(user)
  end
end

def fill_sign_in_form(user)
  fill_in "Email",    with: user.email
  fill_in "Password", with: user.password
  click_button "Sign in"
end

def fill_user_fields(fields)
  fill_in "Name",               with: fields[:name]
  fill_in "Email",              with: fields[:email]
  fill_in "Password",           with: fields[:password]
  fill_in "Confirm Password",   with: fields[:password]
end

RSpec::Matchers.define :have_error_message do |message|
  match do |page|
    expect(page).to have_selector('div.alert.alert-error', text: message)
  end
end

RSpec::Matchers.define :have_success_message do |message|
  match do |page|
    expect(page).to have_selector('div.alert.alert-success', text: message)
  end
end

