module Node
  class Root < Node::Base
    attr_accessor :protocol_section, :derived_section, :results_section
    attr_accessor :errors

    attr_accessor :study

    def initialize(data)
      self.errors = []
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