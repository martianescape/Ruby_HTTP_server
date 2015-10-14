require 'socket'

server = TCPServer.new 2000

while true
  client = server.accept #wait for a client to connect
  client.puts "Hellp !"*10
  client.puts "Now the time is #{Time.now}"
  i = 0
  while i <= 20
    i += 1
    client.puts "i = #{i}"
    sleep 2
  end
  client.close
end
