require_relative 'spec_helper.rb'
require_relative '../modifier.rb'

describe 'Modifier' do
  let(:saleamount_factor) { 1 }
  let(:cancellation_factor) { 0.4 }
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

  describe "#combine_hashes" do
    let(:input_hash) { get_input_hash_for_combine_values }

    subject { modifier.send(:combine_values, input_hash)}
  end

  describe "#combine_hashes" do
    let(:input_file) { File.expand_path('data/sort.csv', File.dirname(__FILE__)) }
    let(:rows) { get_csv_rows(input_file) }

    subject { modifier.send(:combine_hashes, rows)}

    it "should not be nil" do
      is_expected.to eq get_output_hash_for_combine_hashes
    end
  end

  private

  def create_test_csv
    headers = [
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
        row[headers.index(key)] = '1,00'
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

  def get_csv_rows(csv)
    CSV.foreach(csv, Modifier::DEFAULT_CSV_OPTIONS).map do |row|
      row
    end
  end

  def get_output_hash_for_combine_hashes
    {
      "Clicks" => ["0", "5", "3", "1"],
      "Keyword Unique ID" => ["1", "2", "3", "4"],
      "Second" => ["zero", "four", "three", "one"]
    }
  end

  def get_input_hash_for_combine_values
    {
      "Account ID"=>["4", "5"],
      "Account Name"=>[""],
      "Campaign"=>[""],
      "Ad Group"=>[""],
      "Keyword"=>[""],
      "Keyword Type"=>[""],
      "Subid"=>[""],
      "Paused"=>[""],
      "Max CPC"=>[""],
      "Keyword Unique ID"=>[""],
      "ACCOUNT"=>[""],
      "CAMPAIGN"=>[""],
      "BRAND"=>[""],
      "BRAND+CATEGORY"=>[""],
      "ADGROUP"=>[""],
      "KEYWORD"=>[""],
      "Last Avg CPC"=>["", 1],
      "Last Avg Pos"=>[""],
      "Clicks"=>[4],
      "Impressions"=>[""],
      "ACCOUNT - Clicks"=>[""],
      "CAMPAIGN - Clicks"=>[""],
      "BRAND - Clicks"=>[""],
      "BRAND+CATEGORY - Clicks"=>[""],
      "ADGROUP - Clicks"=>[""],
      "KEYWORD - Clicks"=>[""],
      "Avg CPC"=>["1,00"],
      "CTR"=>[""],
      "Est EPC"=>[""],
      "newBid"=>[""],
      "Costs"=>[""],
      "Avg Pos"=>[""],
      "Commission Value"=>["1,00"],
      "ACCOUNT - Commission Value"=>["1,00"],
      "CAMPAIGN - Commission Value"=>["1,00"],
      "BRAND - Commission Value"=>["1,00"],
      "BRAND+CATEGORY - Commission Value"=>["1,00"],
      "ADGROUP - Commission Value"=>["1,00"],
      "KEYWORD - Commission Value"=>["1,00"],
      "number of commissions"=>["1,00"]
    }
  end

  def get_output_hash_for_combine_values
    {
      "Account ID"=>"5",
      "Account Name"=>"",
      "Campaign"=>"",
      "Ad Group"=>"",
      "Keyword"=>"",
      "Keyword Type"=>"",
      "Subid"=>"",
      "Paused"=>"",
      "Max CPC"=>"",
      "Keyword Unique ID"=>"",
      "ACCOUNT"=>"",
      "CAMPAIGN"=>"",
      "BRAND"=>"",
      "BRAND+CATEGORY"=>"",
      "ADGROUP"=>"",
      "KEYWORD"=>"",
      "Last Avg CPC"=> 1,
      "Last Avg Pos"=>nil,
      "Clicks"=>"4",
      "Impressions"=>"",
      "ACCOUNT - Clicks"=>"",
      "CAMPAIGN - Clicks"=>"",
      "BRAND - Clicks"=>"",
      "BRAND+CATEGORY - Clicks"=>"",
      "ADGROUP - Clicks"=>"",
      "KEYWORD - Clicks"=>"",
      "Avg CPC"=>"1,0",
      "CTR"=>"0,0",
      "Est EPC"=>"0,0",
      "newBid"=>"0,0",
      "Costs"=>"0,0",
      "Avg Pos"=>"0,0",
      "Commission Value"=>"2,0",
      "ACCOUNT - Commission Value"=>"2,0",
      "CAMPAIGN - Commission Value"=>"2,0",
      "BRAND - Commission Value"=>"2,0",
      "BRAND+CATEGORY - Commission Value"=>"2,0",
      "ADGROUP - Commission Value"=>"2,0",
      "KEYWORD - Commission Value"=>"2,0",
      "number of commissions"=>"2,0"
    }
  end

=begin
  # remove this
  def test
    modified = input = latest('project_2012-07-27_2012-10-10_performancedata')
    modification_factor = 1
    cancellaction_factor = 0.4
    modifier = Modifier.new(modification_factor, cancellaction_factor)
    modifier.modify(modified, input)

    puts "DONE modifying"
  end

  # remove this
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
=end

end
