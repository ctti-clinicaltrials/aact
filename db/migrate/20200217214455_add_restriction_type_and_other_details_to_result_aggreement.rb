class AddRestrictionTypeAndOtherDetailsToResultAggreement < ActiveRecord::Migration
  def change
    add_column 'ctgov.result_agreements', :restriction_type, :string
    add_column 'ctgov.result_agreements', :other_details, :text
    add_column 'ctgov_beta.result_agreements', :restriction_type, :string
    add_column 'ctgov_beta.result_agreements', :other_details, :text
  end
end
