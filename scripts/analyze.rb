require 'json'

def collect(path, root)
  case root['type']
  when 'String'
    return path
  when "Object"
    root.delete('type')
    return root.map{ |key, child| collect("#{path}.#{key}", child) }.flatten.compact
  when "Array"
    root.delete('type')
    return root.map{ |key, child| collect("#{path}.#{key}", child) }.flatten.compact
  when nil
    return nil
  else
    raise "#{root['type'].inspect} not defined in #{path} #{root.inspect}"
  end
end

root = JSON.parse(File.read('schema.json'))
puts collect('', root)