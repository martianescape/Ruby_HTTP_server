require 'socket'
hostname = 'localhost'
port = 2000
hostname = '127.0.0.1'
#hostname = 'fe80::42f0:2fff:fef7:e5cf/64'
puts "connecting with localhost = #{hostname} at the port #{port}"

s = TCPSocket.open(hostname, port)

while line = s.gets #read lines from the socket
  puts line
end

#while line 
puts "no problem"
