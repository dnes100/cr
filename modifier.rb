require 'csv'
require 'date'

require_relative 'lib/combiner'
require_relative 'constants'
require_relative 'string'
require_relative 'float'

# Modifier processes the input csv data
#   - selects correct column among some,
#   - calculates (commissions) new values depending upon:
#                                           - saleamount_factor,
#                                           - cancellation factor,
#                                           - data type
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
    write_outputs(merger, output)
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

  def write_outputs(merger, output)
    file_name = output.gsub('.txt', '')
    file_index = 0
    loop do
      headers = merger.peek.keys
      CSV.open(file_name + "_#{file_index}.txt", "wb", DEFAULT_CSV_OPTIONS) do |csv|
        csv << headers

        (LINES_PER_FILE - 1).times do
          csv << merger.next
        end
      end
      file_index = file_index.next
    end
  end

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
      hash[key] = hash[key].select { |v| v.to_i != 0 }.last
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
    list_of_rows.reduce({}) do |result, row|
      next if !row

      row.headers.each do |header|
        result[header] ||= []
        result[header] << row[header]
      end

      result
    end
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
