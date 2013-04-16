get '/' do

http = Curl.get("https://www.appannie.com/") do |http|
  http.headers['User-Agent'] = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_8_3) AppleWebKit/537.31 (KHTML, like Gecko) Chrome/26.0.1410.65 Safari/537.31"
  http.headers['Accept'] = 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8'
  http.headers['Accept-Charset'] = 'ISO-8859-1,utf-8;q=0.7,*;q=0.3'
  http.headers['Accept-Encoding'] = 'gzip,deflate,sdch'
  http.headers['Accept-Language'] = 'en-US,en;q=0.8'
  http.headers['Cache-Control']= 'no-cache'
  http.headers['Connection'] = 'keep-alive'
  http.headers['Host'] = 'www.appannie.com'
  http.headers['Pragma'] = 'no-cache'
end
http.header_str

=begin
  c = Curl::Easy.http_post("https://www.appannie.com/account/login/",
                         Curl::PostField.content('username', 'j.treanor@umail.ucc.ie'),
                         Curl::PostField.content('password', '#otdPVJgwUVJ$oJHL8Vr'))

#  echo = c.header_str

  #Remove the last header. This is a cookie we don't need.
  headers = c.header_str.split(/[\r\n]+/)
  headers.delete_at(headers.length-1)

  http_response, *http_headers = headers.map(&:strip)
  http_headers = Hash[http_headers.flat_map{ |s| s.scan(/^(\S+): (.+)/) }]

  if http_headers['Set-Cookie'].nil?
    c.header_str
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