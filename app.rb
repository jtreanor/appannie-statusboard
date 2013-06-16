def param_date_format(date)
    date.strftime("%Y-%m-%d")
end

def appannie_api_token(email,password)
  return "Basic " + Base64.encode64("#{email}:#{password}")
end

def appannie_export(daysBack,email,password,account_id)
  now = Time.now - (1*24*60*60);
  prev = Time.now - ((daysBack+1)*24*60*60)

  token = appannie_api_token(email,password)
  url = "https://api.appannie.com/v1/accounts/#{account_id}/sales?start_date=#{param_date_format(prev)}&end_date=#{param_date_format(now)}&currency=USD&break_down=application%2Bdate"

  api_http = Curl.get(url) do |api_http|
      api_http.headers['Authorization'] = token
      api_http.headers['Accept'] = 'application/json'
  end

  api_http.body_str
end

def appannie_app_details(email,password,account_id)
  token = appannie_api_token(email,password)

  url = "https://api.appannie.com/v1/accounts/#{account_id}/apps"

  api_http = Curl.get(url) do |api_http|
      api_http.headers['Authorization'] = token
      api_http.headers['Accept'] = 'application/json'
  end

  api_http.body_str
end

def statusboard_graph(datasequences,title)
  { :graph => { :title => title, :datasequences => datasequences } }
end

def statusboard_graph_error(message)
  '{
        "graph" : {
        "title" : "Appannie Stats",
        "error" : {
        "message" : "' + message + '",
        "detail" : ""
        },
        "datasequences" : [] }}'
end

def get_account_id_for_token(token)
  url = "https://api.appannie.com/v1/accounts"

  api_http = Curl.get(url) do |api_http|
      api_http.headers['Authorization'] = token
      api_http.headers['Accept'] = 'application/json'
  end

  JSON.parse(api_http.body_str)['account_list'].first['account_id']
end

get '/account_id' do
  email = params[:email]
  password = params[:password]

  token = appannie_api_token(email,password)
  acc = get_account_id_for_token(token)

  return acc.to_s
end

get '/' do
  File.read(File.join('public', 'index.html'))
end

#statusboard graph
get '/graph/:days?' do
  email = params[:email]
  password = params[:password]
  account_id = params[:account_id]

  if email.nil? || password.nil? || account_id.nil?
    return statusboard_graph_error("All params must be set.")
  end

  if !params[:days]
    #default to 7
    params[:days] = 7
  end
  data = appannie_export(params[:days].to_i,email,password,account_id)
  if data.nil? 
    return statusboard_graph_error("Data export error.")
  end

  datasequences = [];

  temp_datasequences = {};


  parsed = JSON.parse(data)

  sales_list = parsed['sales_list']

  if sales_list.nil? 
    return statusboard_graph_error("Data parse error.")
  end

  sales_list.each do |app_day|
    date = DateTime.strptime(app_day['date'],"%Y-%m-%d")
    app_id = app_day['app']
    downloads = app_day['units']['app']['downloads']

    if temp_datasequences[app_id].nil?
      temp_datasequences[app_id] = []
    end

    temp_datasequences[app_id] << { :title => date.strftime("%b %e"), :value => downloads}
  end

  app_details = appannie_app_details(email,password,account_id)

  apps = {}


  JSON.parse(app_details)["app_list"].each do |curr_app|
    apps[curr_app['app_id']] = curr_app['app_name']
  end

  temp_datasequences.each do |id,app|
    datasequences << {:title => apps[id], :datapoints => app}
  end

  days = params[:days]

  output = statusboard_graph(datasequences,"Appannie #{days} days")

  output.to_json

end

def base_url
    @base_url ||= "#{request.env['rack.url_scheme']}://#{request.env['HTTP_HOST']}"
end