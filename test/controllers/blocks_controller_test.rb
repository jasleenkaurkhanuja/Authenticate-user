require "test_helper"

class BlocksControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get blocks_index_url
    assert_response :success
  end

  test "should get block" do
    get blocks_block_url
    assert_response :success
  end

  test "should get unblock" do
    get blocks_unblock_url
    assert_response :success
  end
end
