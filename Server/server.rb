require 'socket'

def start_server(hostname, port = 8080)
  #server_sock = Socket.new(:INET, :STREAM)
  #addr = Socket.pack_sockaddr_in(port, hostname)
  #server_sock.bind(addr)
  #server_sock.listen(3)
  #creates socket, binds it to address, listens
  server_sock = TCPServer.new(hostname, port)
  server_sock.listen(3)
  client_conn, client_addr = server_sock.accept

  p "client_conn = #{client_conn.local_address.ip_unpack}"
  p "client_conn.remote = #{client_conn.remote_address.ip_unpack}"
  p "server_sock = #{server_sock.local_address.ip_unpack}"
  #p "server_sock.remote = #{server_sock.remote_address.ip_unpack}"
  p "client_addr = #{client_addr}"

  server_sock.close

   
end


start_server('0.0.0.0', 8080)
