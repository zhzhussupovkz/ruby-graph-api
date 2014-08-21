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

  #send PUT request
  def put_request url = nil, data = nil, headers = {}
    post_data = data.to_json
    url = @api_url + '/' + url
    uri = URI.parse url
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    req = Net::HTTP::Put.new(uri.request_uri, initheader = headers)
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

  #create node
  def create_node
    headers = {
      'Accept' => 'application/json; charset=UTF-8',
    }
    post_request url = 'node', headers = headers
  end

  #create node with props
  def create_node_with_props data
    headers = {
      'Accept' => 'application/json; charset=UTF-8',
      'Content-Type' => 'application/json',
    }
    post_request 'node', data, headers
  end

  #get node
  def get_node id
    headers = {
      'Accept' => 'application/json; charset=UTF-8',
    }
    get_request '/node/' + id, headers
  end

  #delete node
  def delete_node id
    headers = {
      'Accept' => 'application/json; charset=UTF-8',
    }
    delete_request 'node/' + id, headers
  end

  #get relationship by id
  def get_relationship_by_id id
    headers = {
      'Accept' => 'application/json; charset=UTF-8',
    }
    get_request 'relationship/' + id, headers
  end

  #create relationship
  def create_relationship from_id, to_id, type, props
    data = {
      'to' => @api_url + 'node/' + to_id,
      'type' => type,
      'data' => props,
    }

    headers = {
      'Accept' => 'application/json; charset=UTF-8',
      'Content-Type' => 'application/json',
    }

    post_request 'node/' + from_id + '/relationships', data, headers
  end

  #delete relationship
  def delete_relationship id
    headers = {
      'Accept' => 'application/json; charset=UTF-8',
    }
    delete_request 'relationship/' + id, headers
  end

  #get all properties on a relationship
  def relationship_get_all_props id
    headers = {
      'Accept' => 'application/json; charset=UTF-8',
    }
    get_request 'relationship/' + id + '/properties', headers
  end

  #set all properties on a relationship
  def relationship_set_props id, data
    headers = {
      'Accept' => 'application/json; charset=UTF-8',
      'Content-Type' => 'application/json',
    }

    put_request 'relationship/' + id + '/properties', data, headers
  end

  #get single property on a relationship
  def relationship_get_property id, name
    headers = {
      'Accept' => 'application/json; charset=UTF-8',
    }

    get_request 'relationship/' + id + '/properties/' + name, headers
  end

  #set single property on a relationship
  def relationship_set_property id, name, value
    headers = {
      'Accept' => 'application/json; charset=UTF-8',
    }

    put_request 'relationship/' + id + '/properties/' + name, value, headers
  end

  #get all relationships
  def get_all_relationships
    headers = {
      'Accept' => 'application/json; charset=UTF-8',
    }

    get_request 'relationships/all/', headers
  end

  #get incoming relationships
  def get_in_relationships node_id
    headers = {
      'Accept' => 'application/json; charset=UTF-8',
    }

    get_request 'node/' + node_id + '/relationships/in', headers
  end

  #get outgoing relationships
  def get_out_relationships node_id
    headers = {
      'Accept' => 'application/json; charset=UTF-8',
    }

    get_request 'node/' + node_id + '/relationships/out', headers
  end

end