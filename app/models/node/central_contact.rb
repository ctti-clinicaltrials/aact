module Node
  class CentralContact < Node::Base
    attr_accessor :central_contact_name, :central_contact_phone, :central_contact_e_mail

    def process(root)
      root.central_contacts << ::CentralContact.new(
        nct_id: root.study.nct_id,
        name: central_contact_name,
        contact_type: root.central_contacts.length == 0 ? 'primary' : 'backup',
        phone: central_contact_phone,
        email: central_contact_e_mail
      )
    end
  end
end