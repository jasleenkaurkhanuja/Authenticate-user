require "test_helper"

class FriendshipsControllerTest < ActionDispatch::IntegrationTest
  test "should get create" do
    get friendships_create_url
    assert_response :success
  end

  test "should get accept" do
    get friendships_accept_url
    assert_response :success
  end

  test "should get decline" do
    get friendships_decline_url
    assert_response :success
  end

  test "should get update" do
    get friendships_update_url
    assert_response :success
  end
end
