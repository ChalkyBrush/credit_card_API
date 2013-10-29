class CreateTransactions < ActiveRecord::Migration
  def change
    create_table :transactions do |t|
      t.string :full_name
      t.boolean :complete
      t.string :receipt_id
      t.string :reference_number
      t.string :response_code
      t.string :auth_code
      t.string :amount
      t.string :card_type
      t.string :moneris_id

      t.timestamps
    end
  end
end
