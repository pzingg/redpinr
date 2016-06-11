require 'test_helper'

class FingerprintsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @fingerprint = fingerprints(:one)
  end

  test "should get index" do
    get fingerprints_url
    assert_response :success
  end

  test "should create fingerprint" do
    assert_difference('Fingerprint.count') do
      post fingerprints_url, params: { fingerprint: {  } }
    end

    assert_response 201
  end

  test "should show fingerprint" do
    get fingerprint_url(@fingerprint)
    assert_response :success
  end

  test "should update fingerprint" do
    patch fingerprint_url(@fingerprint), params: { fingerprint: {  } }
    assert_response 200
  end

  test "should destroy fingerprint" do
    assert_difference('Fingerprint.count', -1) do
      delete fingerprint_url(@fingerprint)
    end

    assert_response 204
  end
end
