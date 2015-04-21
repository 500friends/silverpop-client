require 'net/ftp'
require 'csv'

module Silverpop
  module Util
    class << self

      def upload_xml_and_csv(host, username, password, xml_filename, xml_content, csv_filename, csv_lines)
        xml_file = Tempfile.new(xml_filename)
        csv_file = Tempfile.new(csv_filename)
        begin
          xml_file.write(xml_content)
          xml_file.rewind
          CSV.open(csv_file, "wb") do |csv|
            csv_lines.each { |line| csv << line }
          end
          dir = '/upload/'
          Net::SFTP.start(host, username, {password: password}) do |sftp|
            sftp.upload!(xml_file.path, File.join(dir, xml_filename))
            sftp.upload!(csv_file.path, File.join(dir, csv_filename))
          end
        ensure
          xml_file.close!
          csv_file.close!
        end
      end

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