require "application_system_test_case"

class PostsTest < ApplicationSystemTestCase
  test "visitor browses a public post" do
    visit posts_path

    assert_text "Posts"
    click_on "Member's recent post"

    assert_text "By member@example.com"
    assert_link "Original URL", href: "https://example.com/recent"
  end

  test "visitor paginates the public list" do
    18.times do |index|
      Post.create!(author: users(:registered_member), title: "Paged post #{index}", created_at: 1.minute.from_now + index.minutes)
    end

    visit posts_path

    assert_link "Next"
    click_on "Next"

    assert_link "Previous"
    assert_no_link "Next"
  end

  test "author creates, edits, and deletes a post" do
    visit root_path
    click_on "Sign in"
    fill_in "Email address", with: users(:registered_member).email_address
    fill_in "Password", with: "password"
    click_on "Sign in"
    click_on "Create post"

    fill_in "Title", with: "A system post"
    fill_in "Original URL (optional)", with: "example.com/system"
    fill_in "Body (optional)", with: "System test body"
    click_on "Create Post"

    assert_text "Post created."
    assert_link "A system post", href: post_path(Post.order(:id).last)
    assert_link "Edit post"
    assert_button "Delete post"
    assert_no_text "Other author's post"

    click_on "Edit post", match: :first
    fill_in "Title", with: "Updated system post"
    click_on "Update Post"

    assert_text "Post updated."
    assert_text "Updated system post"
    click_on "Delete post", match: :first

    assert_text "Post deleted."
    assert_no_text "Updated system post"
  end

  test "author sees validation errors" do
    visit new_session_path
    fill_in "Email address", with: users(:registered_member).email_address
    fill_in "Password", with: "password"
    click_on "Sign in"
    assert_text "Signed in as member@example.com"
    visit new_my_post_path
    assert_current_path new_my_post_path

    fill_in "Title", with: "Invalid URL post"
    fill_in "Original URL (optional)", with: "mailto:member@example.com"
    assert_field "Title", with: "Invalid URL post"
    assert_field "Original URL (optional)", with: "mailto:member@example.com"
    click_on "Create Post"

    assert_selector "[role=alert]", text: "Check your details", wait: 5
    assert_text "Url must be a valid HTTP or HTTPS URL"
  end
end
