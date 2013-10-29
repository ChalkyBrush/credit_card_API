class Transaction < ActiveRecord::Base
  attr_accessible :full_name, :complete, :receipt_id, :reference_number, :response_code, :auth_code, :amount, :card_type, :moneris_id
  # validates_numericality_of :amount_in_cents, :greater_than => 0, :only_integer => true
end
