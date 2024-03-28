class PendingResult < StudyRelationship

  add_mapping do
    {
      table: :pending_results,
      root: [:annotationSection, :annotationModule, :unpostedAnnotation, :unpostedEvents],
      columns: [
        { name: :event, value: :type },
        { name: :event_date_description, value: :date },
        { name: :event_date, value: :date, convert_to: :date  }
      ]
    }
  end

end
