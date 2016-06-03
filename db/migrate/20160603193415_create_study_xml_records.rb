class CreateStudyXmlRecords < ActiveRecord::Migration
  def change
    create_table :study_xml_records do |t|
      t.xml :content
      t.string :nct_id

      t.timestamps null: false
    end
  end
end
