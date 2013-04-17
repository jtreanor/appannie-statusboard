def param_format(date)
    date.strftime("%Y-%m-%e")
end

get '/' do


  c = Curl::Easy.http_post("https://www.appannie.com/account/login/",
                         Curl::PostField.content('username', 'jtreanor3@gmail.com'),
                         Curl::PostField.content('password', '#otdPVJgwUVJ$oJHL8Vr'))

#  echo = c.header_str

  #Remove the last header. This is a cookie we don't need.
  headers = c.header_str.split(/[\r\n]+/)
  headers.delete_at(headers.length-1)

  http_response, *http_headers = headers.map(&:strip)
  http_headers = Hash[http_headers.flat_map{ |s| s.scan(/^(\S+): (.+)/) }]

  if http_headers['Set-Cookie'].nil?
    puts c.header_str

    '{
        "graph" : {
        "title" : "Appannie Stats",
        "error" : {
        "message" : "Something went wrong.",
        "detail" : ""
        },
        "datasequences" : [] }'
  else

    cookie = http_headers['Set-Cookie'];

    now = DateTime.now;
    lastWeek = Time.now - (8*24*60*60)

    http = Curl.get("https://www.appannie.com/sales/units_data/?account_id=35271&type=units") do |http|
      http.headers['Cookie'] = cookie
    end

    data = http.body_str.split("--end-data--")

    datasequences = [];

    JSON.parse(data.first).each do |app|
      datapoints = []
      app["data"].each do |d|
        puts d.first.to_s[0..-4]
        date = DateTime.strptime(d.first.to_s[0..-4],'%s')

        datapoints << { :title => date.strftime("%b %e"), :value => d[1]}
      end
      datasequences << { :title => app["label"], :datapoints => datapoints }
    end

    output = { :graph => { :title => "Appannie Stats", :datasequences => datasequences } }

    output.to_json



  end


end