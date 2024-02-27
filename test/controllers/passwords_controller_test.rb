require "test_helper"

class PasswordsControllerTest < ActionDispatch::IntegrationTest
  test "should get forgot" do
    get passwords_forgot_url
    assert_response :success
  end

  test "should get reset" do
    get passwords_reset_url
    assert_response :success
  end
end
