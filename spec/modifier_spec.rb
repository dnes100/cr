require_relative 'spec_helper.rb'
require_relative '../modifier.rb'

describe 'Modifier' do
  let(:saleamount_factor) { 1 }
  let(:cancellation_factor) { 2 }
  let(:modifier) { Modifier.new(saleamount_factor, cancellation_factor)}

  before :all do
    create_test_csv
  end

  describe "#sort" do
    let(:input_file) { File.expand_path('data/sort.csv', File.dirname(__FILE__)) }

    subject { modifier.sort(input_file) }

    it { is_expected.to include('.sorted') }

    it "should sort rows by clicks" do
      expect(get_clicks_column(subject)).to eql([5, 3, 1, 0])
    end
  end

  describe "#modify" do
    let(:input_file) { File.expand_path('data/test.csv', File.dirname(__FILE__)) }
    let(:output_file) { File.expand_path('data/output.csv', File.dirname(__FILE__)) }

    subject { modifier.modify(output_file, input_file) }

    it { is_expected.to be_nil }

  end

  private

  def create_test_csv
    headers = [
      Modifier::KEYWORD_UNIQUE_ID,
      Modifier::LAST_VALUE_WINS,
      Modifier::LAST_REAL_VALUE_WINS,
      Modifier::INT_VALUES,
      Modifier::FLOAT_VALUES,
      Modifier::COMMISSIONS,
      Modifier::CANCELLATION_FACTORS
    ].flatten
    content = []
    5.times do |i|
      row = [''] * headers.length
      row[headers.index('Clicks')] = i
      row[0] = i
      [Modifier::COMMISSIONS, Modifier::CANCELLATION_FACTORS].flatten.each do |key|
        row[headers.index(key)] = '1,000'
      end

      content << row
    end
    output = File.expand_path('data/test.csv', File.dirname(__FILE__))
    write(content, headers, output)
  end

  def write(content, headers, output)
    CSV.open(output, "wb", Modifier::DEFAULT_CSV_OPTIONS) do |csv|
      csv << headers
      content.each do |row|
        csv << row
      end
    end
  end

  def get_clicks_column(csv)
    CSV.foreach(csv, col_sep: "\t", headers: :first_row).map do |row|
      row[0].to_i
    end
  end

  def test
    modified = input = latest('project_2012-07-27_2012-10-10_performancedata')
    modification_factor = 1
    cancellaction_factor = 0.4
    modifier = Modifier.new(modification_factor, cancellaction_factor)
    modifier.modify(modified, input)

    puts "DONE modifying"
  end

  def latest(name)
    files = Dir["#{ ENV["HOME"] }/workspace/*#{name}*.txt"]

    files.sort_by! do |file|
      last_date = /\d+-\d+-\d+_[[:alpha:]]+\.txt$/.match file
      last_date = last_date.to_s.match /\d+-\d+-\d+/

      date = DateTime.parse(last_date.to_s)
      date
    end

    throw RuntimeError if files.empty?

    files.last
  end
end
