class CreateCoverLetterCounts < ActiveRecord::Migration[8.0]
  def change
    create_table :cover_letter_counts do |t|
      t.integer :count, default: 0

      t.timestamps
    end

    CoverLetterCount.create! if CoverLetterCount.none?
  end
end
