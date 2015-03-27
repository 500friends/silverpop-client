module Silverpop
  class Transact < Silverpop::Request

    DEFAULT_XTMAIL_URL = "https://transactpilot.silverpop.com/XTMail"

    def xtmailing(campaign_id, email, personalization = {}, save_columns = nil)
      xml = Builder::XmlMarkup.new
      xml.XTMAILING { |x|
        x.CAMPAIGN_ID campaign_id
        x.SHOW_ALL_SEND_DETAIL true
        x.SEND_AS_BATCH false
        x.NO_RETRY_ON_FAILURE false
        x.SAVE_COLUMNS { personalization.each { |k, v| x.COLUMN_NAME k } } if save_columns
        x.RECIPIENT {
          x.EMAIL email
          x.BODY_TYPE 'HTML'
          personalization.each do |k, v|
            x.PERSONALIZATION {
              x.TAG_NAME k
              x.VALUE v
            }
          end
        }
      }
    end
  end
end