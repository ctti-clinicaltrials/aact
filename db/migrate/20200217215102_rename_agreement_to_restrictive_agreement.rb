class RenameAgreementToRestrictiveAgreement < ActiveRecord::Migration
  def change
    rename_column 'ctgov_beta.result_agreements', :agreement, :restrictive_agreement
  end
end
