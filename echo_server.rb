require 'socket'

server = TCPServer.new 2000

client = server.accept

data = client.gets
while data != "exit"
  puts "data = #{data}"
  client.puts "data recieved is #{data}"
  data = client.gets.chomp
  data1 = $stdin.gets.chomp
  puts "data1 = #{data1}"
  client.puts "Server says: #{data1}"
end
client.close

