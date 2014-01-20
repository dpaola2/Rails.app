require 'json'

# See test.rb for usage details

Class.class_eval do
  define_method :define_instance_method_from_string do |name, proc_string|
    block = eval("lambda {#{ proc_string }}")
    define_method name.to_sym, block
    instance_method_list[name.to_sym] = proc_string
    record_change(self.name, name, proc_string)
    block
  end

  define_method :instance_method_list do
    if @instance_method_list.nil?
      @instance_method_list = {}
    end
    @instance_method_list
  end
end

Object.class_eval do
  define_method :method_list do
    self.class.instance_method_list
  end

  define_method :descendants do
    ObjectSpace.each_object(Class).select { |klass| klass < self }
  end
end

def all_classes
  result = []
  ObjectSpace.each_object(Class) do |obj|
    result << obj
  end
  result
end

def all_modules
  result = []
  ObjectSpace.each_object(Module) do |obj|
    result << obj
  end
  result
end

def find_my_objects
  results = []
  ObjectSpace.each_object do |obj|
    if obj.methods.index(:instance_method_list) != nil
      results << obj
    end
  end
  results
end

def record_change(class_name, method_name, proc_string)
  filepath = "changes.json"
  changes = {}
  if File.exists? filepath
    # read file, decode into hash
    file = File.open(filepath, "r")
    changes = JSON.parse(file.read)
  end
  
  # write new values to the hash
  if changes[class_name].nil?
    changes[class_name] = {}
  end
  changes[class_name][method_name] = proc_string
  
  # write the file
  File.open(filepath, "w") do |f|
    f.write(JSON.pretty_generate(changes))
  end
end
