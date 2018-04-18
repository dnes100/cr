# input:
# - two enumerators returning elements sorted by their key
# - block calculating the key for each element
# - block combining two elements having the same key or a single element, if there is no partner
# output:
# - enumerator for the combined elements
#
class Combiner
  attr_accessor :key_extractor

  def initialize(&key_extractor)
    self.key_extractor = key_extractor
  end

  def combine(*enumerators)
    Enumerator.new do |yielder|
      last_values = Array.new(enumerators.size)
      in_progress = enumerators.any?
      while in_progress
        last_values.each_with_index do |value, index|
          if value.nil? && enumerators[index]
            begin
              last_values[index] = enumerators[index].next
            rescue StopIteration
              enumerators[index] = nil
            end
          end
        end

        in_progress = enumerators.any? || !last_values.compact.empty?
        if in_progress
          min_key = get_min_key(last_values)
          values = Array.new(last_values.size)
          last_values.each_with_index do |value, index|
            if key(value) == min_key
              values[index] = value
              last_values[index] = nil
            end
          end
          yielder.yield(values)
        end
      end
    end
  end

  private

  def key(value)
    return if value.nil?

    key_extractor.call(value)
  end

  def get_min_key(values)
    keys = values.map { |e| key(e) }

    keys.min do |a, b|
      if a.nil? && b.nil?
        0
      elsif a.nil?
        1
      elsif b.nil?
        -1
      else
        a <=> b
      end
    end
  end
end
