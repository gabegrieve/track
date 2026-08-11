require "test_helper"

class ServiceBudgetTest < ActiveSupport::TestCase
  setup do
    @project = Project.create!(name: "Website", client_name: "Acme", hourly_rate_cents: 15_000)
  end

  test "converts entered hours to exact budget minutes" do
    budget = @project.service_budgets.create!(name: "Web design", budget_hours: "12.5", cadence: :project)

    assert_equal 750, budget.budget_minutes
    assert_equal 12.5, budget.budget_hours
  end

  test "requires a positive budget allowance" do
    budget = @project.service_budgets.new(name: "Asset design", budget_minutes: 0)

    assert_not budget.valid?
    assert_includes budget.errors[:budget_minutes], "must be greater than 0"
  end
end
