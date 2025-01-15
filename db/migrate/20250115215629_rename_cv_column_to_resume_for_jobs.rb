class RenameCvColumnToResumeForJobs < ActiveRecord::Migration[8.0]
  def change
    rename_column :jobs, :cv, :resume
  end
end
