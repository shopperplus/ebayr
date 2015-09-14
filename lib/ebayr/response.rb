# -*- encoding : utf-8 -*-
module Ebayr #:nodoc:
  # A response to an Ebayr::Request.
  class Response < Record
    def initialize(request, response)
      @request = request
      @command = @request.command if @request
      @response = response
      @body = response.body if @response
      hash = self.class.from_xml(@body) if @body
      response_data = hash["#{@command}Response"] if hash
      @success = response_data['Ack'] != 'Failure'
      super(response_data) if response_data
      if Ebayr.logger && failure?
        Ebayr.logger.error "#{request.command} at #{Time.now}"
        Ebayr.logger.error request.input
        Ebayr.logger.error errors_info
      end
    end

    def success?
      @success
    end

    def failure?
      !@success
    end

    def errors_info_str
      errors_info.collect.map{|x| x[:LongMessage]}.join("\n")
    end

    def errors_info
      errors = self[:Errors]
      if errors.is_a? Array
        errors.select{|x| x[:SeverityCode] == 'Error'}
      else
        [errors]
      end
    end
  end
end
