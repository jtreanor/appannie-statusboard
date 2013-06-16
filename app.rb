def param_date_format(date)
    date.strftime("%Y-%m-%d")
end

def appannie_api_token(email,password)
  return "Basic " + Base64.encode64("#{email}:#{password}")
end

def appannie_export_with_token(daysBack,token,account_id)
  now = Time.now - (1*24*60*60);
  prev = Time.now - ((daysBack+1)*24*60*60)

  url = "https://api.appannie.com/v1/accounts/#{account_id}/sales?start_date=#{param_date_format(prev)}&end_date=#{param_date_format(now)}&currency=USD&break_down=application%2Bdate"

  appannie_api_request(url,token)
end

def appannie_export_with_credentials(daysBack,email,password,account_id)
  token = appannie_api_token(email,password)

  appannie_export_with_token(daysBack,token,account_id)
end

def appannie_app_details(token,account_id)
  url = "https://api.appannie.com/v1/accounts/#{account_id}/apps"

  appannie_api_request(url,token)
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
  url = 'https://api.appannie.com/v1/accounts'

  account_response = JSON.parse(appannie_api_request(url,token))

  if account_response.nil?
    return 0
  elsif account_response['account_list'].nil?
    return -3
  elsif account_response['account_list'].size <= 0
    return -1
  elsif account_response['account_list'].first['account_id'].nil?
    return -2
  end
  
  account_response['account_list'].first['account_id']
end

def appannie_api_request(url,token)
  api_http = Curl.get(url) do |api_http|
      api_http.headers['Authorization'] = token
      api_http.headers['Accept'] = 'application/json'
  end

  api_http.body_str
end

get '/account_id' do
  token = params[:token]
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
  token  = params[:token]
  account_id = params[:account_id]

  if token.nil?
    token = appannie_api_token(email,password)
  end

  puts "Account ID: " + account_id
  puts "Token: " + token

  if account_id.nil?
    return statusboard_graph_error("Account id must be provided")
  end

  if !params[:days]
    #default to 7
    params[:days] = 7
  end

  data = appannie_export_with_token(params[:days].to_i,token,account_id)

  puts data

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

    temp_datasequences[app_id] << { :title => date, :value => downloads}
  end

  app_details = appannie_app_details(token,account_id)

  apps = {}


  JSON.parse(app_details)["app_list"].each do |curr_app|
    apps[curr_app['app_id']] = curr_app['app_name']
  end

  temp_datasequences.each do |id,app|
    app.sort_by { |hsh| hsh[:title] }

    app.each do |t|
      t[:title] = t[:title].strftime("%b %e")
    end

    datasequences << {:title => apps[id], :datapoints => app}
  end

  days = params[:days]

  output = statusboard_graph(datasequences,"Appannie units #{days} days")

  output.to_json

end

#statusboard graph
get '/rank/:days?' do
  email = params[:email]
  password = params[:password]
  token  = params[:token]
  account_id = params[:account_id]
  app_id = params[:app_id]

  if token.nil?
    token = appannie_api_token(email,password)
  end

  puts "Account ID: " + account_id
  puts "Token: " + token

  if account_id.nil?
    return statusboard_graph_error("Account id must be provided")
  end

  if !params[:days]
    #default to 7
    params[:days] = 7
  end

  url = 'https://api.appannie.com/v1/accounts/#{account_id}/apps/{app_id}/ranks?start_date=#{param_date_format(prev)}&end_date=#{param_date_format(now)}'
  data = appannie_api_request(url,token)

  data

  if data.nil?
    return statusboard_graph_error("Data export error.")
  end

end