class CreateDonationItems < ActiveRecord::Migration
  def change
    create_table :donation_items do |t|
      t.string :description
      t.integer :quantity
      t.string :unit

      t.timestamps null: false
    end
  end
end
