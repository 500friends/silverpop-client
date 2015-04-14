module Silverpop
  class JobResultError < StandardError; end
  class JobCannotComplete < StandardError; end
  class LimitExceeded < StandardError; end
  class UserSessionInvalidOrExpired < StandardError; end
end
