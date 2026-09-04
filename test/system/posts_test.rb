require "application_system_test_case"

class PostsTest < ApplicationSystemTestCase
  test "visitor browses a public post" do
    visit root_path

    assert_selector ".app-shell--posts-index"
    assert_selector "ol[aria-label='Public posts']"
    assert_link "example.com", href: "https://example.com/recent"
    click_on "Member's recent post"

    assert_selector ".app-shell--post-show"
    assert_text "By member@example.com"
    assert_selector ".app-post__title"
    assert_link "example.com", href: "https://example.com/recent"
  end

  test "visitor paginates the public list" do
    18.times do |index|
      Post.create!(author: users(:registered_member), title: "Paged post #{index}", created_at: 1.minute.from_now + index.minutes)
    end

    visit root_path

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
    assert_selector "ol[aria-label='Public posts']"
    click_on "Create post"
    assert_current_path new_my_post_path
    assert_selector ".app-shell--post-form input.app-primary-action[value='Create Post']", count: 1

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
    visit new_registration_path
    fill_in "Email address", with: "post-errors-#{SecureRandom.uuid}@example.com"
    fill_in "Password", with: "password"
    fill_in "Confirm password", with: "password"
    click_on "Sign up"
    assert_current_path root_path
    assert_selector "ol[aria-label='Public posts']"
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
