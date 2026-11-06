require "test_helper"

class CoinsControllerTest < ActionDispatch::IntegrationTest
  test "should get new" do
    get coins_new_url
    assert_response :success
  end

  test "should get create" do
    get coins_create_url
    assert_response :success
  end

  test "should get edit" do
    get coins_edit_url
    assert_response :success
  end

  test "should get update" do
    get coins_update_url
    assert_response :success
  end

  test "should get destroy" do
    get coins_destroy_url
    assert_response :success
  end
end
