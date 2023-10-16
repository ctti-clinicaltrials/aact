class StudyJsonRecord::ProcessorV2
  def initialize(json)
    @json = json
  end
  
  def protocol_section
    if ENV['STUDY_SECTIONS']
      StudyRecord.find_by(nct_id: nct_id, type: "StudyRecord::ProtocolSection")&.content
    else
      content.dig('Study', 'ProtocolSection')
    end
  end

  def results_section
    if ENV['STUDY_SECTIONS']
      StudyRecord.find_by(nct_id: nct_id, type: "StudyRecord::ResultsSection")&.content
    else
      content.dig('Study', 'ResultsSection')
    end
  end
  
  def derived_section
    if ENV['STUDY_SECTIONS']
      StudyRecord.find_by(nct_id: nct_id, type: "StudyRecord::DerivedSection")&.content
    else
      content.dig('Study', 'DerivedSection')
    end
  end

  def annotation_section
    if ENV['STUDY_SECTIONS']
      StudyRecord.find_by(nct_id: nct_id, type: "StudyRecord::AnnotationSection")&.content
    else
      content.dig('Study', 'AnnotationSection')
    end
  end

  def document_section
    if ENV["STUDY_SECTIONS"]
      StudyRecord.find_by(nct_id: nct_id, type: "StudyRecord::DocumentSection")&.content
    else
      content.dig('Study', 'DocumentSection')
    end
  end
  
 # leave this empty for now
  def process
  end
end