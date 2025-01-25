class AddAppliedToJobs < ActiveRecord::Migration[8.0]
  def change
    add_column :jobs, :applied, :boolean, default: false
  end
end
