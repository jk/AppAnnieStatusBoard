require 'httparty'
require 'json'
require 'date'

#####################################################################
# Configuration Start
#####################################################################

# For more information about the parameters, see https://appannie.zendesk.com/entries/23215097-2-App-Sales
username = "" # App Annie username
password = "" # App Annie password
account_id = "" # App Annie account connection id. You can get all account connection info by calling /v1/accounts
graph_title = ""
graph_type = "line"
hide_totals = false
days_to_show = 30
date_format = "%b %-d" # Date format for x-axis. Default format is "Apr 20"
products = [
    { :title => "Product 1", :app_id => 000000000, :color => "green" },
    { :title => "Product 2", :app_id => 000000000, :color => "blue" }
]

outputFile = "/Users/tim/Dropbox/Status\ Board/salesboard.json"

#####################################################################
# Configuration End
#####################################################################

options = { :basic_auth => { :username => username , :password => password } }
end_date = Date.today
start_date = (end_date - days_to_show)

data_sequences = []
min_total = 0
max_total = 0

products.each do |p|
  sales_data = []
  response = HTTParty.get("https://api.appannie.com/v1/accounts/#{account_id}/apps/#{p[:app_id]}/sales?break_down=date&start_date=#{start_date.to_s}&end_date=#{end_date.to_s}", options)

  sales = response.parsed_response["sales_list"]
  sales.reverse!

  sales.each do |datapoint|
    date = Date.parse(datapoint["date"])
    date_string = date.strftime(date_format)

    value = datapoint["revenue"]["app"]["downloads"]

    min_total = value.to_i if value.to_i < min_total || min_total == 0
    max_total = value.to_i if value.to_i > max_total

    sales_data << {
      :title => date_string,
      :value => value
    }
  end

  # Add the product to the data sequences.
  data_sequences << { :title => p[:title], :color => p[:color], :datapoints => sales_data }
end

sales_graph = {
  :graph => {
    :title => graph_title,
    :type => graph_type,
    :yAxis => {
      :hide => hide_totals,
      :units => {
        :prefix => "$",
        :min_total => min_total,
        :max_total => max_total
      }
    },
    :datasequences => data_sequences
  }
}

File.open(outputFile, "w") do |f|
  f.write(sales_graph.to_json)
end
