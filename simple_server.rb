require 'socket'

server = TCPServer.new('127.0.0.1', 2000)

while true
  client = server.accept #wait for a client to connect
  client.puts "Server is connected at #{Time.now}"
  client.puts "enter the file containing the http request"
  filename = client.gets.chomp
  puts "Http request is in #{filename}"
  file = open(filename, 'r')
  line = request_line = file.readline
  client.puts "request_line = #{request_line}"
  request_header = "" 
  while line[0] != "\n"
    line = file.readline
    request_header += line
  end
  client.puts "request_headers = #{request_header}"
  
  client.close
end
