require "test_helper"

class TabTrabajadorsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get tab_trabajadors_index_url
    assert_response :success
  end

  test "should get new" do
    get tab_trabajadors_new_url
    assert_response :success
  end

  test "should get show" do
    get tab_trabajadors_show_url
    assert_response :success
  end

  test "should get create" do
    get tab_trabajadors_create_url
    assert_response :success
  end

  test "should get edit" do
    get tab_trabajadors_edit_url
    assert_response :success
  end

  test "should get update" do
    get tab_trabajadors_update_url
    assert_response :success
  end

  test "should get destroy" do
    get tab_trabajadors_destroy_url
    assert_response :success
  end
end
