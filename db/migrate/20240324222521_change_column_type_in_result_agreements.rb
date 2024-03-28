class ChangeColumnTypeInResultAgreements < ActiveRecord::Migration[6.0]
  def up
    change_column 'ctgov_v2.result_agreements', :pi_employee, :boolean, using: "CASE WHEN LOWER(pi_employee) = 'yes' THEN TRUE WHEN LOWER(pi_employee) = 'no' THEN FALSE ELSE NULL END"
    change_column 'ctgov_v2.result_agreements', :restrictive_agreement, :boolean, using: "CASE WHEN LOWER(restrictive_agreement) = 'yes' THEN TRUE WHEN LOWER(restrictive_agreement) = 'no' THEN FALSE ELSE NULL END"
  end

  def down
    change_column 'ctgov_v2.result_agreements', :pi_employee, :text
    change_column 'ctgov_v2.result_agreements', :restrictive_agreement, :text
  end
end
