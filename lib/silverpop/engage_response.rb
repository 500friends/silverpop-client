require 'builder'
require 'faraday_middleware'

module Silverpop
  class EngageResponse

    attr_accessor :response, :result, :success, :job_id, :fault

    def initialize(response)
      @response = response
      @result = response['Envelope']['Body']['RESULT']
      @success = @result['SUCCESS'] == 'TRUE'
      @job_id = @success ? @result['JOB_ID'] : nil
      @fault = @success ? nil : response['Envelope']['Body']['Fault']
    end

    def method_missing(method, *args, &block)
      key = method.upcase
      return @result[key] if !self.respond_to?(method) && @result && @result.has_key?(key)
      super
    end

  end
end