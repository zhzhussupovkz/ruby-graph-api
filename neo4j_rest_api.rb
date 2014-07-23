=begin
/*

The MIT License (MIT)

Copyright (c) 2014 Zhussupov Zhassulan zhzhussupovkz@gmail.com

Permission is hereby granted, free of charge, to any person obtaining a copy of
this software and associated documentation files (the "Software"), to deal in
the Software without restriction, including without limitation the rights to
use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
the Software, and to permit persons to whom the Software is furnished to do so,
subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

*/
=end

require 'net/http'
require 'net/https'
require 'openssl'
require 'base64'
require 'digest'
require 'cgi'

class Neo4jRestApi

  def initialize host = 'localhost', port = 7474
    @api_url = 'https://' + host + ':' + port + '/db/data'
  end

  #send GET request
  def get_request url = nil, headers = {}
    url = @api_url + '/' + url
    uri = URI.parse url
    http = Net::HTTP.new uri.host uri.port
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    req = Net::HTTP::Get.new(uri.request_uri , initheader = headers)
    res = http.request req
    data = res.body
    result = JSON.parse(data)
  end

  #send POST request
  def post_request url = nil, data = nil, headers = {}
    post_data = data.to_json
    url = @api_url + '/' + url
    uri = URI.parse url
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    req = Net::HTTP::Post.new(uri.request_uri, initheader = headers)
    req.body = post_data
    res = http.request req
    data = res.body
    result = JSON.parse(data)
  end

  #send DELETE request
  def delete_request url = nil, headers = {}
    url = @api_url + '/' + url
    uri = URI.parse url
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    req = Net::HTTP::Delete.new(uri.request_uri, initheader = headers)
    res = http.request req
    data = res.body
    result = JSON.parse(data)
  end

  #cypher queries
  def cypher_query query = nil, params = {}
    data = { 'query' => query, 'params' => params }
    headers = {
      'Accept' => 'application/json; charset=UTF-8',
      'Content-Type' => 'application/json',
    }
    post_request 'cypher', data, headers
  end

  #streaming
  def streaming
    headers = {
      'Accept' => 'application/json; charset=UTF-8',
      'X-Stream' => 'true',
    }
    get_request '', headers
  end

  #list all property keys
  def property_keys
    headers = { 'Accept' => 'application/json; charset=UTF-8' }
    get_request 'propertykeys', headers
  end

end