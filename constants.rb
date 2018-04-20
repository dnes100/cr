class Modifier
  module Constants
    KEYWORD_UNIQUE_ID = 'Keyword Unique ID'
    LAST_VALUE_WINS = [
      'Account ID', 'Account Name', 'Campaign', 'Ad Group', 'Keyword', 'Keyword Type',
      'Subid', 'Paused', 'Max CPC', 'Keyword Unique ID', 'ACCOUNT', 'CAMPAIGN', 'BRAND',
      'BRAND+CATEGORY', 'ADGROUP', 'KEYWORD'
    ]
    LAST_REAL_VALUE_WINS = ['Last Avg CPC', 'Last Avg Pos']
    INT_VALUES = [
      'Clicks', 'Impressions', 'ACCOUNT - Clicks', 'CAMPAIGN - Clicks', 'BRAND - Clicks',
      'BRAND+CATEGORY - Clicks', 'ADGROUP - Clicks', 'KEYWORD - Clicks'
    ]
    FLOAT_VALUES = ['Avg CPC', 'CTR', 'Est EPC', 'newBid', 'Costs', 'Avg Pos']
    COMMISSIONS = [
      'Commission Value', 'ACCOUNT - Commission Value', 'CAMPAIGN - Commission Value',
      'BRAND - Commission Value', 'BRAND+CATEGORY - Commission Value',
      'ADGROUP - Commission Value', 'KEYWORD - Commission Value'
    ]
    CANCELLATION_FACTORS = ['number of commissions']

    LINES_PER_FILE = 120_000
    DEFAULT_CSV_OPTIONS = { :col_sep => "\t", :headers => :first_row }
  end
end
