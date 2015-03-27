require 'builder'
require 'faraday_middleware'

module Silverpop
  class Request

    DEFAULT_XMLAPI_URL = 'https://api.silverpop.com/XMLAPI'

    def initialize(connection, url = nil)
      @connection = connection
      @url = url || DEFAULT_XMLAPI_URL
    end

    def xml_envelope(&block)
      xml = Builder::XmlMarkup.new
      xml.Envelope { |x| x.Body { block.call(x) } }
    end

    def build_options(builder, options, defaults = {})
      options.each do |name, value|
        name = name.upcase
        value ||= defaults[name]
        if value.is_a?(Array)
          builder.__send__(:method_missing, name) {
            value.each { |hash| build_options(builder, hash, defaults) }
          }
        else
          builder.tag! name, value
        end
      end
    end

    def build_columns(builder, columns)
      columns.each do |column|
        builder.COLUMN {
          column.each do |name, value|
            builder.tag! name.upcase, value
          end
        }
      end
    end

    def post(body)
      response = @connection.post do |request|
        request.url @url
        request.headers['Content-type'] = "text/xml"
        request.body = body
      end
      response.body
    end

    def xml(method, *args, &block)
      send(method, *args, &block)
    end

    def invoke_api(method, *args, &block)
      post(xml(method, *args, &block))
    end
  end
end