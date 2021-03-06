require 'test_helper'

class UserTest < ActiveSupport::TestCase
  def setup
    @user = User.new(name:"Example User", email:"user@example.com", password:"foobar", password_confirmation:"foobar")
  end

  test "should me valid" do
    assert @user.valid?
  end

  test "name should be present" do
    @user.name = " "
    assert_not @user.valid?
  end

  test "email should be present" do
    @user.email = " "
    assert_not @user.valid?
  end

  test "name should not be too long" do
    @user.name = "a" * 51
    assert_not @user.valid?
  end

  test "email should not be too long" do
    @user.email = "a" * 244 + "@example.com"
    assert_not @user.valid?
  end

  test "email validation should accept valid addresses" do
    valid_addresses = %w[user@example,com user_at_foo.org user.name@example. foo@bar_baz.com foo@bar+baz.com]
    valid_addresses.each do |invalid_address|
      @user.email = invalid_address
      assert_not @user.valid?, "#{invalid_address.inspect} should be valid"
    end
  end

  test "email adresses should be unique" do
    duplicate_user = @user.dup
    duplicate_user.email = @user.email.upcase
    @user.save
    assert_not duplicate_user.valid?
  end

  test "password should be present (nonblank)" do
    @user.password = @user.password_confirmation = " " * 6
    assert_not @user.valid?
  end

  test "password should have a minimum length" do
    @user.password = @user.password_confirmation = "a" * 5
    assert_not @user.valid?
  end

  test "authenticated? should return false for a user with nil digest" do
    assert_not @user.authenticated?(:remember, '')
  end

  test "associated microposts should be destroyed" do
    @user.save
    @user.microposts.create!(content: "Lorem ipsum")
    assert_difference 'Micropost.count', -1 do
      @user.destroy
    end
  end

  test "should follow and unfollow a user" do
    akari = users(:akari)
    mimimi = users(:mimimi)
    assert_not akari.following?(mimimi)
    akari.follow(mimimi)
    assert akari.following?(mimimi)
    assert mimimi.followers.include?(akari)
    akari.unfollow(mimimi)
    assert_not akari.following?(mimimi)
  end

  test "feed should have the right posts" do
    akari = users(:akari)
    mimimi = users(:mimimi)
    lana = users(:lana)
    # ???????????????????????????????????????????????????
    lana.microposts.each do |post_following|
      assert akari.feed.include?(post_following)
    end
    # ??????????????????????????????
    akari.microposts.each do |post_self|
      assert akari.feed.include?(post_self)
    end
    # ????????????????????????????????????????????????????????????
    mimimi.microposts.each do |post_unfollowed|
      assert_not akari.feed.include?(post_unfollowed)
    end
  end
end
