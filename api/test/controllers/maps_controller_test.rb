require 'test_helper'

class MapsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @map = maps(:one)
  end

  test "should get index" do
    get maps_url
    assert_response :success
  end

  test "should create map" do
    assert_difference('Map.count') do
      post maps_url, params: { map: {  } }
    end

    assert_response 201
  end

  test "should show map" do
    get map_url(@map)
    assert_response :success
  end

  test "should update map" do
    patch map_url(@map), params: { map: {  } }
    assert_response 200
  end

  test "should destroy map" do
    assert_difference('Map.count', -1) do
      delete map_url(@map)
    end

    assert_response 204
  end
end
