class ChangeReportedEventsAttributes < ActiveRecord::Migration
  def change

    remove_column :reported_events, :ctgov_group_enumerator, :integer
    remove_column :reported_events, :ctgov_group_id, :string
    add_column    :reported_events, :ctgov_group_code, :string
    add_column    :reported_events, :group_id, :integer, references: :groups

    remove_column :reported_events, :group_title, :string
    remove_column :reported_events, :group_description, :string

    remove_column :reported_events, :category, :string
    add_column    :reported_events, :organ_system, :string

    remove_column :reported_events, :title, :string
    add_column    :reported_events, :adverse_event_term, :string

    remove_column    :reported_events, :frequency_threshold, :string
    add_column    :reported_events, :frequency_threshold, :integer

    add_column    :reported_events, :vocab, :string
    add_column    :reported_events, :assessment, :string

  end
end
