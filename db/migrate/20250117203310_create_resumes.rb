class CreateResumes < ActiveRecord::Migration[8.0]
  def change
    create_table :resumes do |t|
      t.string :label
      t.text :content

      t.timestamps
    end
  end
end
