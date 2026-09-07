require "application_system_test_case"

class CommentsTest < ApplicationSystemTestCase
  test "member posts replies edits cancels and deletes while replies survive" do
    sign_in_member
    visit post_path(posts(:member_recent_post))
    fill_in "Comment", with: "A new discussion\nSecond line"
    click_on "Post comment"
    assert_text "Comment posted."
    root = Comment.find_by!(body: "A new discussion\nSecond line")
    assert_selector "#comment_#{root.id}:focus"
    page_url = page.current_url
    within("#comment_#{root.id}") { click_on "Reply" }
    assert_equal page_url, page.current_url
    assert_field "Reply"
    fill_in "Reply", with: "A nested reply"
    click_on "Post reply"
    assert_text "Comment posted."
    assert_text "A nested reply"
    within("#comment_#{root.id}") { click_on "Edit" }
    assert_equal page_url, page.current_url
    fill_in "Edit comment", with: "Edited discussion"
    click_on "Save changes"
    assert_text "Comment updated."
    assert_text "Edited discussion"
    within("#comment_#{root.id}") { click_on "Edit" }
    fill_in "Edit comment", with: "Cancelled change"
    click_on "Cancel"
    assert_current_path post_path(posts(:member_recent_post)), ignore_query: true
    assert_text "Edited discussion"
    assert_no_text "Cancelled change"
    within("#comment_#{root.id}") { click_on "Delete" }
    assert_equal post_path(posts(:member_recent_post)), URI.parse(page.current_url).path
    assert_text "text is retained internally"
    click_on "Cancel"
    assert_current_path post_path(posts(:member_recent_post)), ignore_query: true
    visit post_path(posts(:member_recent_post))
    assert_text "Edited discussion"
    within("#comment_#{root.id}") { click_on "Delete" }
    assert_equal post_path(posts(:member_recent_post)), URI.parse(page.current_url).path
    click_on "Delete comment"
    assert_text "Comment deleted."
    within("#comment_#{root.id}") do
      assert_text "[deleted]"
      assert_no_link "Reply"
      assert_no_link "Edit"
      assert_no_text "member@example.com"
    end
    assert_text "A nested reply"
    assert_no_text "Edited discussion"
    page.save_screenshot(Rails.root.join("tmp/screenshots/comments-deleted.png"))
  end

  test "validation preserves input and keyboard can post and follow a reply" do
    sign_in_member
    visit post_path(posts(:member_older_post))
    assert_text "No comments yet."
    fill_in "Comment", with: "   "
    click_on "Post comment"
    assert_selector "[role=alert]", text: "Body can't be blank"
    page.save_screenshot(Rails.root.join("tmp/screenshots/comments-errors.png"))
    field = find_field("Comment")
    field.set("")
    field.send_keys("Keyboard comment", :tab, :enter)
    assert_text "Comment posted."
    comment = Comment.find_by!(body: "Keyboard comment")
    visit post_path(posts(:member_older_post), anchor: "comment_#{comment.id}")
    find("#comment_#{comment.id}").send_keys(:tab, :enter)
    assert_field "Reply"
    fill_in "Reply", with: "Keyboard reply"
    find_field("Reply").send_keys(:tab, :enter)
    assert_text "Comment posted."
    assert_text "Keyboard reply"
  end

  test "deep threads wrap at mobile width and retain parent links" do
    parent = comments(:member_follow_up)
    12.times do |index|
      parent = parent.post.comments.create!(parent: parent, author: users(:registered_member),
        body: "Reply #{index}: #{'longword' * 40}")
    end
    users(:other_author).destroy!
    visit post_path(posts(:member_recent_post))
    assert_text "[deleted user]"
    assert_selector ".comment", count: 15
    page.save_screenshot(Rails.root.join("tmp/screenshots/comments-desktop.png"))
    # Chrome window sizing has a minimum width; emulate an actual 320px viewport.
    page.driver.browser.execute_cdp("Emulation.setDeviceMetricsOverride",
      width: 320, height: 900, deviceScaleFactor: 1, mobile: false)
    visit post_path(posts(:member_recent_post), anchor: "comment_#{parent.id}")
    assert_equal 320, page.evaluate_script("window.innerWidth")
    assert_selector "#comment_#{parent.id} a", text: "In reply to parent comment"
    assert page.evaluate_script("document.documentElement.scrollWidth <= window.innerWidth")
    within("#comment_#{parent.id}") { click_on "In reply to parent comment" }
    assert_current_path(/#comment_#{parent.parent_id}\z/, url: true)
    page.save_screenshot(Rails.root.join("tmp/screenshots/comments-mobile.png"))
  ensure
    page.driver.browser.execute_cdp("Emulation.clearDeviceMetricsOverride")
    page.current_window.resize_to(1400, 1400)
  end

  private
    def sign_in_member
      visit new_session_path
      fill_in "Email address", with: users(:registered_member).email_address
      fill_in "Password", with: "password"
      click_on "Sign in"
      assert_current_path root_path, wait: 5
    end
end
