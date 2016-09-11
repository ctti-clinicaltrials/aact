class DictionaryController < ApplicationController
  def show
    @schema_diagram=ClinicalTrials::FileManager.schema_diagram
    @data_dictionary=ClinicalTrials::FileManager.data_dictionary
  end
end
