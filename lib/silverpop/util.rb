require 'net/ftp'
require 'csv'

module Silverpop
  module Util
    class << self
      def wait_for_job_completion(client, job_id, retries = 3, timeout = 1)
        response = client.get_job_status(job_id)
        raise Silverpop::JobResultError unless response.success
        status = response.result['JOB_STATUS']
        while response.success && status != 'COMPLETE'
          raise Silverpop::JobCannotComplete unless ['WAITING', 'RUNNING'].include?(status)
          raise Silverpop::LimitExceeded if retries <= 0
          sleep timeout
          response = client.get_job_status(job_id)
          status = response.result['JOB_STATUS']
          retries -= 1
        end
        true
      end
    end
  end
end