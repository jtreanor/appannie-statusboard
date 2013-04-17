def param_date_format(date)
    date.strftime("%Y-%m-%d")
end

def appannie_export(daysBack,email,password)
  c = Curl::Easy.http_post("https://www.appannie.com/account/login/",
                         Curl::PostField.content('username', email),
                         Curl::PostField.content('password', password))

#  echo = c.header_str

  #Remove the last header. This is a cookie we don't need.
  headers = c.header_str.split(/[\r\n]+/)
  headers.delete_at(headers.length-1)

  http_response, *http_headers = headers.map(&:strip)
  http_headers = Hash[http_headers.flat_map{ |s| s.scan(/^(\S+): (.+)/) }]

  if http_headers['Set-Cookie'].nil?
    puts c.header_str
    puts email
    puts password

    return false
  else

    cookie = http_headers['Set-Cookie'];

    now = Time.now - (1*24*60*60);
    prev = Time.now - ((daysBack+1)*24*60*60)

    url = "https://www.appannie.com/sales/units_data/?account_id=35271&type=units&s=#{param_date_format(prev)}&e=#{param_date_format(now)}"
    puts url


    http = Curl.get(url) do |http|
      http.headers['Cookie'] = cookie
    end

    http.body_str.split("--end-data--")
  end

end

def statusboard_graph(datasequences,title)
  { :graph => { :title => "Appannie Stats", :datasequences => datasequences } }
end

def statusboard_graph_error
  '{
        "graph" : {
        "title" : "Appannie Stats",
        "error" : {
        "message" : "Something went wrong.",
        "detail" : ""
        },
        "datasequences" : [] }}'
end


get '/' do
  File.read(File.join('public', 'index.html'))
end

#statusboard graph
get '/graph/:days?' do
  email = params[:email]
  password = params[:password]

  if !params[:days]
    #default to 7
    params[:days] = 7
  end
  data = appannie_export(params[:days].to_i,email,password)
  if ! data.kind_of?(Array)
    return statusboard_graph_error
  end

  datasequences = [];

  #The first is the json data
  JSON.parse(data.first).each do |app|
    datapoints = []
    app["data"].each do |d|
      date = DateTime.strptime(d.first.to_s[0..-4],'%s')

      datapoints << { :title => date.strftime("%b %e"), :value => d[1]}
    end
    datasequences << { :title => app["label"], :datapoints => datapoints }
  end

  output = statusboard_graph(datasequences,"Appannie Stats")

  output.to_json

end