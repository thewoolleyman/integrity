require File.dirname(__FILE__) + "/helpers"
require "helpers/acceptance/textfile_notifier"

class BuildNotificationsTest < Test::Unit::AcceptanceTestCase
  story <<-EOS
    As an administrator,
    I want to setup notifiers on my projects
    So that I get alerts with every build
  EOS

  before(:each) do
    # This is needed before any available notifier is unset
    # in the global #before
    load "helpers/acceptance/textfile_notifier.rb"
  end

  scenario "an admin sets up a notifier for a project that didn't have any" do
    git_repo(:my_test_project).add_successful_commit
    Project.gen(:my_test_project, :notifiers => [], :uri => git_repo(:my_test_project).path)
    rm_f "/tmp/textfile_notifications.txt"

    login_as "admin", "test"

    visit "/my-test-project"

    click_link "Edit Project"
    check "enabled_notifiers_textfile"
    fill_in "File", :with => "/tmp/textfile_notifications.txt"
    click_button "Update Project"

    click_button "manual build"

    notification = File.read("/tmp/textfile_notifications.txt")
    notification.should =~ /=== Built #{git_repo(:my_test_project).short_head} successfully ===/
    notification.should =~ /Build #{git_repo(:my_test_project).head} was successful/
    notification.should =~ %r(http://www.example.com/my-test-project/commits/#{git_repo(:my_test_project).head})
    notification.should =~ /Commit Author: John Doe/
    notification.should =~ /Commit Date: (.+)/
    notification.should =~ /Commit Message: This commit will work/
    notification.should =~ /Build Output:\n\nRunning tests...\n/
  end
end
