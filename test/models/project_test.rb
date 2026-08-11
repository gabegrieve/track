require "test_helper"

class ProjectTest < ActiveSupport::TestCase
  test "requires basic client and rate details" do
    project = Project.new

    assert_not project.valid?
    assert_includes project.errors[:name], "can't be blank"
    assert_includes project.errors[:client_name], "can't be blank"
  end
end
