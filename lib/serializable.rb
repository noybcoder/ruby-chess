# frozen_string_literal: true

# The Serializable module provides functionality for serializing and deserializing
# game objects, enabling save/load game functionality.
module Serializable
  # Public: Collects all variables (both class and instance) from an object
  # @param obj [Object] The object to inspect
  # @return [Array<Symbol>] Array of variable names as symbols
  def gather_variables(obj)
    obj.class.instance_variables + obj.instance_variables
  end

  # Public: Organizes variables into a hash with their current values
  # @param obj [Object] The object to inspect
  # @return [Hash{Symbol => Object}] Hash of variable names to their values
  # @note Prioritizes instance variables over class variables when both exist
  def organize_variables(obj)
    gather_variables(obj).each_with_object({}) do |var, dict|
      inst_var = obj.instance_variable_get(var)
      variable = inst_var.nil? ? obj.class.instance_variable_get(var) : inst_var
      dict[var] = variable
    end
  end

  # Public: Serializes an object to a binary string using Marshal
  # @param hashed_obj [Hash] The object to serialize
  # @return [String] Binary string representation of the object
  def serialize(hashed_obj)
    Marshal.dump(hashed_obj)
  end

  # Public: Extracts the class name from an instance variable
  # @param instance [Object] The instance to inspect
  # @return [Class] The class object
  # @example "@Player1" becomes Player
  def class_name(instance)
    name = instance.to_s.gsub(/^@|\d+$/, '').capitalize
    Object.const_get(name)
  end

  # Public: Gets the first class variable from a class
  # @param instance [Object] The instance to inspect
  # @return [Symbol] The class variable name
  def class_variable(instance)
    class_name(instance).instance_variables[0]
  end

  # Public: Converts a class variable name to a method name
  # @param instance [Object] The instance to inspect
  # @return [String] The method name without '@' prefix
  def class_method(instance)
    class_variable(instance).to_s.gsub('@', '')
  end

  # Public: Decrements a counter variable in the instance's class
  # @param instance [Object] The instance to inspect
  # @return [Integer] The decremented count
  def decrement_variable_count(instance)
    count = class_name(instance).public_send(class_method(instance))
    count - 1
  end

  # Public: Reconstructs an object from serialized data
  # @param obj [Object] The target object to restore into
  # @param save [Hash] The saved state data
  def deserialize(obj, save)
    obj.instance_variables.each do |component|
      decrement_variable_count(component)
      piece = obj.instance_variable_get(component)
      piece.instance_variables.each do |attribute|
        piece.instance_variable_set(attribute, save[component].instance_variable_get(attribute))
      end
    end
  end

  # Public: Saves game state to a file
  # @param progress [String] Serialized game data
  # @param file_name [String] Path to save file (default: 'save.marshal')
  def save_data(progress, file_name = 'save.marshal')
    File.open(file_name, 'wb') { |file| file.write(progress) }
  end

  # Public: Loads game state from a file
  # @param file_name [String] Path to save file (default: 'save.marshal')
  # @return [Object] The deserialized game state
  def load_data(file_name = 'save.marshal')
    Marshal.load(File.read(file_name, mode: 'rb'))
  end
end
