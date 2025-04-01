require 'json'

module Serializable
  def gather_variables(obj)
    obj.class.instance_variables + obj.instance_variables
  end

  def organize_variables(obj)
    gather_variables(obj).reduce({}) do |dict, var|
      inst_var = obj.instance_variable_get(var)
      variable = inst_var.nil? ? obj.class.instance_variable_get(var) : inst_var
      dict[var] = variable
      dict
    end
  end

  def serialize_data(obj)
    JSON.dump(organize_variables(obj))
  end

  def save(file_name = 'save.txt', progress)
    File.write(file_name, progress)
  end

  def load(file_name = 'save.txt')
    progress = File.read(file_name)
    JSON.parse(progress)
  end

end
