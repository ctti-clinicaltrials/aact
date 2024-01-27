module Node
  class Base
    attr_reader :raw

    def self.attribute(*attribute_names)
      class_eval do
        attribute_names.each do |key|
          Node::Root.attribute_list << key
          attr_accessor key
        end
      end
    end

    def initialize(data, root)
      @raw = data
      data.each do |key, val|
        # if self.class == Node::CentralContactList
        #   a = 1
        # end
        case val
        when String
          instance_variable_set("@#{key.underscore}", val)
        when Array
          case val.first
          when Hash
            type = "Node::#{key}".constantize
            list = val.map{|k| type.new(k, root) }
            instance_variable_set("@#{key.underscore.pluralize}", list)
          when String
            instance_variable_set("@#{key.underscore.pluralize}", val)
          else
            item = "Node::#{key}".constantize.new(val, root)
            instance_variable_set("@#{key.underscore}", item)
          end
        else
          begin
            item = "Node::#{key}".constantize.new(val, root)
            instance_variable_set("@#{key.underscore}", item)
          rescue => e
            # puts e.message.red
            root.errors << "Node::#{key} not found"
          end
        end
      end
    end

    def process(root)
      # puts self.class.to_s.underscore
      instance_variables.each do |var|
        next if var == :@raw
        val = instance_variable_get(var)
        case val
        when String
          # puts "missing #{var}"
        when Array
          val.each do |item|
            item.process(root)
          end
        else
          begin
            val.process(root)
          rescue => e
            a = 1
          end
        end
      end
    end

    # def inspect
    #   "..."
    # end

    private

    def get_boolean(val)
      return nil unless val
      return true if val.downcase=='yes'||val.downcase=='y'||val.downcase=='true'
      return false if val.downcase=='no'||val.downcase=='n'||val.downcase=='false'
    end

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