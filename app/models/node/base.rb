module Node
  class Base
    attr_reader :data

    def initialize(data, root)
      data.each do |key, val|
        case val
        when String
          instance_variable_set("@#{key.underscore}", val)
        when Array
          case val.first
          when Hash
            type = "Node::#{key}".constantize
            list = val.map{|k| type.new(k, root) }
            instance_variable_set("@#{key.underscore.pluralize}", list)
          else
            item = "Node::#{key}".constantize.new(val, root)
            instance_variable_set("@#{key.underscore}", item)
          end
        else
          begin
            item = "Node::#{key}".constantize.new(val, root)
            instance_variable_set("@#{key.underscore}", item)
          rescue
            root.errors << "Node::#{key} not found"
          end
        end
      end
    end

    def process(root)
      puts self.class.to_s.underscore
      instance_variables.each do |var|
        val = instance_variable_get(var)
        case val
        when String
          puts "missing #{var}"
        else
          val.process(root)
        end
      end
    end

    # def inspect
    #   "..."
    # end

    private

    def get_date(str)
      begin
        str.try(:to_date)
      rescue
        nil
      end
    end

    def convert_date(str)
      return unless str

      converted_date = get_date(str)
      return unless converted_date
      return converted_date.end_of_month if str.count(' ') == 1

      converted_date
    end
  end
end