require 'faraday/upload_io'

module Restforce
  UploadIO = Faraday::UploadIO
end

module Faraday
  module Parts
    class ParamPart
      def build_part(boundary, name, value)
        part = ''
        part << "--#{boundary}\r\n"
        part << "Content-Disposition: form-data; name=\"#{name.to_s}\";\r\n"
        part << "Content-Type: application/json\r\n"
        part << "\r\n"
        part << "#{value}\r\n"
      end
    end
  end
end
