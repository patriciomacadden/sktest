require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "downcases and strips email_address" do
    user = User.new(email_address: " DOWNCASED@EXAMPLE.COM ")

    assert_equal "downcased@example.com", user.email_address
  end

  test "requires a unique email address" do
    user = User.new(email_address: users(:registered_reader).email_address, password: "password")

    assert_not user.valid?
    assert_includes user.errors[:email_address], "has already been taken"
  end

  test "requires a valid email address" do
    [ "", "not-an-email" ].each do |email_address|
      user = User.new(email_address:, password: "password")

      assert_not user.valid?
      assert_includes user.errors[:email_address], "is invalid" unless email_address.empty?
    end
  end
end
