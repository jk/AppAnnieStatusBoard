require 'httparty'
require 'json'
require 'date'

# For more information about the parameters, see https://appannie.zendesk.com/entries/23215097-2-App-Sales
username = "" # App Annie username
password = "" # App Annie password
account_id = "" # App Annie account connection id. You can get all account connection info by calling /v1/accounts
app_id = "" # Apple App ID, can be found in iTunes Connect
graph_title = ""
graph_type = "line"
hide_totals = true
days_to_show = 30

outputFile = "/Users/tim/Dropbox/Status\ Board/salesboard.json"


options = { :basic_auth => { :username => username , :password => password } }
end_date = Date.today
start_date = (end_date - days_to_show)
response = HTTParty.get("https://api.appannie.com/v1/accounts/#{account_id}/apps/#{app_id}/sales?break_down=date&start_date=#{start_date.to_s}&end_date=#{end_date.to_s}", options)

months = { 
    "1" => "Jan",
    "2" => "Feb",
    "3" => "Mar",
    "4" => "Apr",
    "5" => "May",
    "6" => "Jun",
    "7" => "Jul",
    "8" => "Aug",
    "9" => "Sep",
    "10" => "Oct",
    "11" => "Nov",
    "12" => "Dec"
}

data_points = []
sales = response.parsed_response["sales_list"]
sales.reverse!
sales.each do |datapoint|

  date = Date.parse(datapoint["date"])
  date_string = "#{months["#{date.month}"]} #{date.day}"

  data_points << {
    :title => date_string,
    :value => datapoint["revenue"]["app"]["downloads"]
  }
end

sales_graph = {
  :graph => {
    :title => graph_title,
    :type => graph_type,
    :yAxis => {
      :hide => hide_totals,
      :units => {
        :prefix => "$"
      }
    },
    :datasequences => [
      {
        :title => "Sales",
        :color => "green",
        :datapoints => data_points
      }
    ]
  }
}

File.open(outputFile, "w") do |f|
  f.write(sales_graph.to_json)
end