get '/' do

  #http = Curl.post("http://www.google.com/", {:foo => "bar"})
  #puts http.body_str

  c = Curl::Easy.http_post("https://www.appannie.com/account/login/",
                         Curl::PostField.content('username', 'jtreanor3@gmail.com'),
                         Curl::PostField.content('password', '#otdPVJgwUVJ$oJHL8Vr'))

  puts c.header_str

  headers = c.header_str.split(/[\r\n]+/)
  headers.delete_at(headers.length-1)

  http_response, *http_headers = headers.map(&:strip)
  http_headers = Hash[http_headers.flat_map{ |s| s.scan(/^(\S+): (.+)/) }]

  puts Hirb::Helpers::AutoTable.render(http_headers)

  cookie = http_headers['Set-Cookie'];

  puts "Cookie: " + cookie

  http = Curl.get('https://www.appannie.com/sales/units_data/?account_id=35271&type=units&s=2013-01-01&e=2013-03-12') do |http|
    http.headers['Cookie'] = cookie
  end

  http.body_str

end