require 'csv'
require 'date'

require_relative 'lib/combiner'
require_relative 'constants'
require_relative 'string'
require_relative 'float'

# Description will go here
#
class Modifier

  include Constants

  attr_accessor :saleamount_factor, :cancellation_factor

  def initialize(saleamount_factor, cancellation_factor)
    @saleamount_factor = saleamount_factor
    @cancellation_factor = cancellation_factor
  end

  def modify(output, input)
    input = sort(input)

    input_enumerator = lazy_read(input)
    combined_enumerator = combine_enumerators(input_enumerator)
    merger = get_merger_enumerator(combined_enumerator)

    done = false
    file_index = 0
    file_name = output.gsub('.txt', '')
    while not done do
      CSV.open(file_name + "_#{file_index}.txt", "wb", { :col_sep => "\t", :headers => :first_row, :row_sep => "\r\n" }) do |csv|
        headers_written = false
        line_count = 0
        while line_count < LINES_PER_FILE
          begin
            merged = merger.next
            if not headers_written
              csv << merged.keys
              headers_written = true
              line_count +=1
            end
            csv << merged
            line_count +=1
          rescue StopIteration
            done = true
            break
          end
        end
        file_index += 1
      end
    end
  end

  def sort(file)
    output = "#{file}.sorted"
    content_as_table = parse(file)
    headers = content_as_table.headers
    index_of_key = headers.index('Clicks')
    content = content_as_table.sort_by { |a| -a[index_of_key].to_i }
    write(content, headers, output)

    return output
  end

  private

  def combine_enumerators(*enumerators)
    combiner = Combiner.new do |value|
      value[KEYWORD_UNIQUE_ID]
    end

    combiner.combine(*enumerators)
  end

  def get_merger_enumerator(enumerator)
    Enumerator.new do |yielder|
      loop do
        list_of_rows = enumerator.next
        merged = combine_hashes(list_of_rows)
        yielder.yield(combine_values(merged))
      end
    end
  end

  def combine(merged)
    result = []
    merged.each do |_, hash|
      result << combine_values(hash)
    end
    result
  end

  def combine_values(hash)
    LAST_VALUE_WINS.each do |key|
      hash[key] = hash[key].last
    end
    LAST_REAL_VALUE_WINS.each do |key|
      hash[key] = hash[key].select {|v| not (v.nil? or v == 0 or v == '0' or v == '')}.last
    end
    INT_VALUES.each do |key|
      hash[key] = hash[key][0].to_s
    end
    FLOAT_VALUES.each do |key|
      hash[key] = hash[key][0].from_german_to_f.to_german_s
    end
    CANCELLATION_FACTORS.each do |key|
      hash[key] = (cancellation_factor * hash[key][0].from_german_to_f).to_german_s
    end
    COMMISSIONS.each do |key|
      hash[key] = (cancellation_factor * saleamount_factor * hash[key][0].from_german_to_f).to_german_s
    end

    hash
  end

  def combine_hashes(list_of_rows)
    keys = []
    list_of_rows.each do |row|
      next if row.nil?
      row.headers.each do |key|
        keys << key
      end
    end
    result = {}
    keys.each do |key|
      result[key] = []
      list_of_rows.each do |row|
        result[key] << (row.nil? ? nil : row[key])
      end
    end
    result
  end

  def parse(file)
    CSV.read(file, DEFAULT_CSV_OPTIONS)
  end

  # TODO use .lazy instead?
  def lazy_read(file)
    Enumerator.new do |yielder|
      CSV.foreach(file, DEFAULT_CSV_OPTIONS) do |row|
        yielder.yield(row)
      end
    end
  end

  def write(content, headers, output)
    CSV.open(output, "wb", { :col_sep => "\t", :headers => :first_row, :row_sep => "\r\n" }) do |csv|
      csv << headers
      content.each do |row|
        csv << row
      end
    end
  end
end
