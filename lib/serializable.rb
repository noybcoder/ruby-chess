# frozen_string_literal: true

require 'oj'

module Serializable
  def gather_variables(obj)
    obj.class.instance_variables + obj.instance_variables
  end

  def organize_variables(obj)
    gather_variables(obj).each_with_object({}) do |var, dict|
      inst_var = obj.instance_variable_get(var)
      variable = inst_var.nil? ? obj.class.instance_variable_get(var) : inst_var
      dict[var] = variable
    end
  end

  def serialize(hashed_obj)
    Oj.dump(hashed_obj, mode: :object)
  end

  def class_name(instance)
    name = instance.to_s.gsub(/^@|\d+$/, '').capitalize
    Object.const_get(name)
  end

  def class_variable(instance)
    class_name(instance).instance_variables[0]
  end

  def class_method(instance)
    class_variable(instance).to_s.gsub('@', '')
  end

  def decrement_variable_count(instance)
    count = class_name(instance).public_send(class_method(instance))
    count - 1
  end

  def deserialize(obj, save)
    obj.instance_variables.each do |var|
      obj.instance_variable_set(var, save[var])
      decrement_variable_count(var)
    end
  end

  def save_data(progress, file_name = 'save.json')
    File.open(file_name, 'wb') { |file| file.write(progress) }
  end

  def load_data(file_name = 'save.json')
    Oj.load(File.read(file_name, mode: 'rb'))
  end
end
