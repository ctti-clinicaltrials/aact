class AddRestrictionTypeAndOtherDetailsToResultAggreement < ActiveRecord::Migration[4.2]
  def change
    add_column 'ctgov.result_agreements', :restriction_type, :string
    add_column 'ctgov.result_agreements', :other_details, :text
    add_column 'ctgov.result_agreements', :restrictive_agreement, :string
  end
end
