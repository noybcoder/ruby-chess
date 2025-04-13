# frozen_string_literal: true

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
    Marshal.dump(hashed_obj)
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
    obj.instance_variables.each do |component|
      decrement_variable_count(component)
      piece = obj.instance_variable_get(component)
      piece.instance_variables.each do |attribute|
        piece.instance_variable_set(attribute, save[component].instance_variable_get(attribute))
      end
    end
  end

  def save_data(progress, file_name = 'save.marshal')
    File.open(file_name, 'wb') { |file| file.write(progress) }
  end

  def load_data(file_name = 'save.marshal')
    Marshal.load(File.read(file_name, mode: 'rb'))
  end
end
