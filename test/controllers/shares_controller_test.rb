require "test_helper"

class SharesControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get shares_index_url
    assert_response :success
  end

  test "should get create" do
    get shares_create_url
    assert_response :success
  end

  test "should get delete" do
    get shares_delete_url
    assert_response :success
  end
end
