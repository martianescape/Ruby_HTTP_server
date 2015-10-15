require 'socket'



def request_line_handler(line, client)
  array = line.split(' ')
  method, resource, version = array
  client.puts "method is #{method}"
  client.puts "resource is #{resource}"
  client.puts "version is #{version}"
end

def request_header_handler(line, client)
  client.gets
  array = line.split("\n")
  header_hash = {}
  array.each do
    |headerline|
    header_hash[headerline.split(":")[0]] = headerline.split(":")[1][1..-1]
  end
    client.puts "hhash is #{header_hash}"
end

server = TCPServer.new('127.0.0.1', 2000)
while true
  client = server.accept #wait for a client to connect
  client.puts "Server is connected at #{Time.now}"
  client.puts "enter the file containing the http request"
  filename = client.gets.chomp
  file = open(filename, 'r')
  line = request_line = file.readline
  request_line_handler(request_line, client)
  client.puts "request_line = #{request_line}"
  request_header = "" 
  while line[0] != "\n"
    line = file.readline
    request_header += line
  end
  request_header_handler(request_header, client)
  client.close
end
