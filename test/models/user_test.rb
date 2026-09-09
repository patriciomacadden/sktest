require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "normalizes email addresses" do
    user = User.new(email: "  HELLO@example.com ", password: "password", password_confirmation: "password")

    assert user.save
    assert_equal "hello@example.com", user.email
  end

  test "requires unique email addresses" do
    duplicate = User.new(email: users(:maya).email, password: "password", password_confirmation: "password")

    assert_not duplicate.valid?
    assert_includes duplicate.errors[:email], "has already been taken"
  end
end
