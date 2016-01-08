require 'socket'

request = {}

$content_type = {
  'html' => "text/html",
  "css"  => "text/css",
  "js"   => "application/javascript",
  "jpeg" => "image/jpeg",
  "jpg"  => "image/jpg",
  "png"  => "image/png",
  "gif"  => "image/gif",
  "ico"  => "image/x-icon",
  "text" => "text/plain",
  "txt"  => "text/plain",
  "json" => "application/json"
}

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
  p $content_type
  p "requested request[header][path] = #{request['header']['path']} "
  response = {}
  session_handler
  method_handler(request, response)
end

def session_handler
  
end

def method_handler(request, response)
  p "the method requested is #{request['header']['method']}"
  $method[request['header']['method']].call(request, response)
end

$get_handler = lambda { |request, response|
  p "get handler is switched on"
  #remember that we need to handle dynamic handler
  static_file_handler(request, response)
}

$post_handler = lambda {
}

$head_handler = lambda {

}

$method = {
  'GET'   => $get_handler,
  'POST'  => $post_handler,
  'HEAD'  => $head_hanldler
}

def static_file_handler(request, response)
  
  begin
    filename = "/users/revu/programs/Ruby_server/Server/web_files" + 
      request['header']['path']   
    file = open(filename, 'r')
    response['content'] = file.read
    response['Content-type'] = $content_type[request['header']['path'].split(".")[-1].downcase]
    p "content type = #{response['Content-type']}"
    ok_200_handler(request, response)
  
  rescue IOError, Errno::ENOENT
    p 'resuce in use'     
    err_404_handler(request, response)
  end
end

def ok_200_handler(request, response)
  request['status'] = "HTTP/1.1 200 OK"
  response['Content-Length'] = response['content'].length.to_s
  response_handler(request, response)
end

def err_404_handler(request, response)
end

def response_handler(request, response)
  time = Time.new
  response['Date'] = "#{time.day}/#{time.month}/#{time.year} #{time.hour}:#{time.min}:#{time.sec}"
  response['Connection'] = 'close'
  response['Server'] = 'my_server0.1'
   
end

start_server('0.0.0.0', 8080)
