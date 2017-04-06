require 'test_helper'

class LoginFlowTest < Capybara::Rails::TestCase
  def setup
    @user_one = users(:one)
    @user_two = users(:two)
    visit new_user_session_path
  end

  test 'should get login page' do
    assert page.has_content? 'Log in'
    assert page.has_content? 'Register'
  end

  test 'visiting login should not get sign up page' do
    refute page.has_content? 'Password confirmation'
  end

  test 'should login with valid username/password' do
    fill_in 'Email', with: @user_one.email
    fill_in 'Password', with: 'password'

    click_on 'Log in'

    assert_current_path root_path
    assert page.has_content? 'Welcome'
  end
end
