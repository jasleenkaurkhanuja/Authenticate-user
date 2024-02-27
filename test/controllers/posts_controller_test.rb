require "test_helper"

class PostsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get posts_index_url
    assert_response :success
  end

  test "should get create" do
    get posts_create_url
    assert_response :success
  end

  test "should get show" do
    get posts_show_url
    assert_response :success
  end

  test "should get showlikes" do
    get posts_showlikes_url
    assert_response :success
  end

  test "should get showcomments" do
    get posts_showcomments_url
    assert_response :success
  end

  test "should get togglelike" do
    get posts_togglelike_url
    assert_response :success
  end

  test "should get comment" do
    get posts_comment_url
    assert_response :success
  end
end
