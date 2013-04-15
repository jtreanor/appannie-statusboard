get '/' do

  c = Curl::Easy.http_post("https://www.appannie.com/account/login/",
                         Curl::PostField.content('username', 'jtreanor3@gmail.com'),
                         Curl::PostField.content('password', '#otdPVJgwUVJ$oJHL8Vr'))

  puts c.header_str
=begin
  #Remove the last header. This is a cookie we don't need.
  headers = c.header_str.split(/[\r\n]+/)
  headers.delete_at(headers.length-1)

  http_response, *http_headers = headers.map(&:strip)
  http_headers = Hash[http_headers.flat_map{ |s| s.scan(/^(\S+): (.+)/) }]

  if http_headers['Set-Cookie'].nil?
    "Something went wrong"
  else

    cookie = http_headers['Set-Cookie'];

    http = Curl.get('https://www.appannie.com/sales/units_data/?account_id=35271&type=units&s=2013-03-04&e=2013-03-12') do |http|
      http.headers['Cookie'] = cookie
    end

    data = http.body_str.split("--end-data--")

    datasequences = [];

    JSON.parse(data.first).each do |app|
      datapoints = []
      app["data"].each do |d|
        datapoints << { :title => d.first, :value => d[1]}
      end
      datasequences << { :title => app["label"], :datapoints => datapoints }
    end

    output = { :graph => { :title => "Appannie Data", :datasequences => datasequences } }

    output.to_json

  end
=end

end