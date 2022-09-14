module Node
  class OversightModule < Node::Base
    attr_accessor :oversight_has_dmc, :is_fda_regulated_device, :is_fda_regulated_drug, :is_unapproved_device, :is_us_export, :is_ppsd

    def process(root)
      root.study.has_dmc = oversight_has_dmc
      root.study.is_fda_regulated_drug = get_boolean(is_fda_regulated_drug)
      root.study.is_fda_regulated_device = get_boolean(is_fda_regulated_device)
      root.study.is_unapproved_device = get_boolean(is_unapproved_device)
      root.study.is_ppsd = get_boolean(is_ppsd)
      root.study.is_us_export = get_boolean(is_us_export)
    end
  end
end