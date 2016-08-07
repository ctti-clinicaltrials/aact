class RemoveAgreementType < ActiveRecord::Migration
  def change
    remove_column :result_agreements, :agreement_type
  end
end
