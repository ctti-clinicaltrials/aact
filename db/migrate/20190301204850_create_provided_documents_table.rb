class CreateProvidedDocumentsTable < ActiveRecord::Migration

  def change

    create_table "ctgov.provided_documents", force: :cascade do |t|
      t.string  "nct_id"
      t.string  "document_type"
      t.boolean "has_protocol"
      t.boolean "has_icf"
      t.boolean "has_sap"
      t.date    "document_date"
      t.string  "url"
    end

  end

end
