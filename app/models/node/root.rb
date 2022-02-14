module Node
  class Root < Node::Base
    def self.models(*model_names)
      class_eval do
        @model_list = [] unless @model_list
        model_names.each do |key|
          @model_list << key
          attr_accessor key
        end
      end
    end

    def self.model_collections(*model_names)
      class_eval do
        model_names.each do |key|
          @model_collections = [] unless @model_collections
          model_names.each do |key|
            @model_collections << key
            attr_accessor key
          end
        end
      end
    end

    def self.model_list
      @model_list
    end

    def self.model_collections_list
      @model_collections
    end

    attr_accessor :protocol_section, :derived_section, :results_section
    attr_accessor :errors

    models :study, :detailed_description, :brief_summary, :design, :eligibility, :participant_flow
    model_collections :result_groups, :browse_conditions, :central_contacts

    def initialize(data)
      self.errors = []

      # initialize arrays
      self.class.model_collections_list.each do |key|
        self.send("#{key}=", [])
      end

      data.each do |key, val|
        case val
        when String
          instance_variable_set("@#{key.underscore}", val)
        else
          begin
            item = "Node::#{key}".constantize.new(val, self)
            instance_variable_set("@#{key.underscore}", item)
          rescue
            errors << "Node::#{key} not found"
          end
        end
      end
    end

    def process
      self.study = Study.new

      protocol_section.process(self)
      derived_section.process(self)
      results_section.process(self) if results_section
    end
  end
end