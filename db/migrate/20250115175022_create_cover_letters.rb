class CreateCoverLetters < ActiveRecord::Migration[8.0]
  def change
    create_table :cover_letters do |t|
      t.references :job, null: false, foreign_key: true
      t.text :body

      t.timestamps
    end
  end
end
