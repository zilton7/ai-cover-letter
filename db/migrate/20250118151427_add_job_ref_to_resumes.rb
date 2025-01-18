class AddJobRefToResumes < ActiveRecord::Migration[8.0]
  def change
    remove_column :jobs, :resume, :string
    add_reference :resumes, :job, index: true
  end
end
