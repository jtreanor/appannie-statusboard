require 'sinatra'

get '/' do

  http = Curl.post("http://www.google.com/", {:foo => "bar"})
  puts http.body_str

  cookie = 'secure_sessionId=".eJxNzD0OwjAMQGG1_GwdYOUCTBFngAmhDgyeIzexhEXlNLEDYkBi5dYsHVif9L1P-87NHjZKqpxkoqKsRmK5_UI3V6-GxfLi0sDWY7Wbr0rFDxjuJDEv4fCkAQXHl3FQhyGkKuZOqHQWJVE2flCfIo3H2ayg-ztxzOt-d63uB9uTNLY:1URLng:xrmPFVQsJZJ3sZbgaRtCYNWqQGc"; Path=/; secure, sessionId=".eJxNzD0OwjAMQGG1_GwdYOUCTBFngAmhDgyeIzexhEXlNLEDYkBi5dYsHVif9L1P-87NHjZKqpxkoqKsRmK5_UI3V6-GxfLi0sDWY7Wbr0rFDxjuJDEv4fCkAQXHl3FQhyGkKuZOqHQWJVE2flCfIo3H2ayg-ztxzOt-d63uB9uTNLY:1URLng:ovz3fIhv7tw_EGPuGkr9jh2iZ8s"; Path=/';

  http = Curl.get('https://www.appannie.com/sales/units_data/?account_id=35271&type=units&s=2013-01-01&e=2013-03-12') do|http|
    http.headers['Cookie'] = cookie
end
  http.body_str
end