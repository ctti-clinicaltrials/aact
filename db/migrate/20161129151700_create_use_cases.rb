class CreateUseCases < ActiveRecord::Migration
  def change
    create_table :use_cases do |t|
      t.string 'status'
      t.string 'title'
      t.string 'brief_summary'
      t.text   'detailed_description'
      t.string 'url'
      t.string 'submitter_name'
      t.string 'contact_info'
      t.string 'email'
      t.binary 'image'
      t.string 'remote_image_url'
      t.timestamps null: false
    end

    create_table :use_case_attachments do |t|
      t.integer 'use_case_id'
      t.string 'file_name'
      t.binary 'payload'
      t.timestamps null: false
    end
  end
end
