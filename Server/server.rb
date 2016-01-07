require 'socket'

request = {}

def start_server(hostname, port = 8080)
  #server_sock = Socket.new(:INET, :STREAM)
  #addr = Socket.pack_sockaddr_in(port, hostname)
  #server_sock.bind(addr)
  #server_sock.listen(3)
  #creates socket, binds it to address, listens
  server_sock = TCPServer.new(hostname, port)
  server_sock.listen(3)
  client_conn, client_addr = server_sock.accept

  handle_http_request(client_conn)
  server_sock.close

end

def handle_http_request(client_conn)

  request = {}
  request["socket"] = client_conn

  p "i client_conn = #{client_conn.local_address.ip_unpack}"
  p "client_conn.remote = #{client_conn.remote_address.ip_unpack}"
  client_conn.puts "don't worry dude connected"
  header_str, body_str = get_http_header(request)
  p "header_str, = #{header_str}"
 # p "body_str, = #{body_str}"
  if !header_str
    return
  end
  request['header'] = header_parser(header_str)
  p "printing request"

  request.each do |r|
    p r
  end
  
  if request["header"].has_key?("Content-Length")
    p "found content length"
    content_length = request["header"]["Content-Length"].to_i
    p "content_length = #{content_length}"
    request["body"] = get_http_body(request, body_str, content_length)
  end
  #if !request.empty?
    request_handler(request)
  #else
   # client_conn.close
  #end
  p "request body = #{request["body"]}"
end


def get_http_header(request, data = '')
  if /\r\n\r\n/ =~ data
    header_str, body_str = data.split(/\n\n/) 
    return header_str, body_str
  end
  buff = request["socket"].recv(2400)
  if !buff; return '',''; end
  p "data = #{data}"
  p "buff = #{buff}"
  get_http_header(request, data+buff)
end

def get_http_body(request, body_str, content_length)
  if body_str.length == content_length; return body_str; end
  buff = request["socket"].recv(2048)
  if !buff; return ''; end
  get_http_body(request, body_str + buff, content_length)
end


def header_parser(header_str)
  headers_list = header_str.split("\r\n")
  header_request = {}
  header_request["method"], header_request["path"], header_request["protocol"] = headers_list.shift.split(' ')
  headers_list.each do |header|
    key, value = header.split(': ',2)
    header_request[key] = value
  end
  header_request['Cookie'] = cookie_parser(header_request)
  return header_request
end

def cookie_parser(header_request)
  if header_request.has_key?("Cookie")
    cookies = header_request["Cookie"].split(";")
    client_cookies = {}
    cookies.each do |cookie|
      head, body = cookie.split("=",2)
      client_cookies[head] = body
    end
    return client_cookies
  end
  return ""
end



def request_handler(request)
  response = {}
  session_handler
  method_handler
end

def session_handler
  
end

start_server('0.0.0.0', 8080)
