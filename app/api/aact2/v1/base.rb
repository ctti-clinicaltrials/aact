require 'grape-swagger'

module AACT2
  module V1
    class Base < Grape::API
      include Grape::Kaminari
      version 'v1', using: :path
      content_type :json, 'application/json'
      format :json
      default_format :json
      formatter :json, Grape::Formatter::ActiveModelSerializers
      prefix :api

      helpers do
        def logger
          Rails.logger
        end

        def validation_error!(object)
          error_payload = {
            error: '400',
            reason: 'validation failed',
            suggestion: 'Fix the following invalid fields and resubmit',
            errors: []
          }
          object.errors.messages.each do |field, errors|
            errors.each do |message|
              error_payload[:errors] << {
                field: field,
                message: message
              }
            end
          end
          error!(error_payload, 400)
        end
      end

      rescue_from ActiveRecord::RecordNotFound do |e|
        missing_object = ''
        m = e.message.match(/find\s(\w+)/)
        if m
          missing_object = m[1]
        end
        error_json = {
          "error" => "404",
          "reason" => "#{missing_object} Not Found",
          "suggestion" => "you may have mistyped the #{missing_object} id"
        }
        error!(error_json, 404)
      end
      mount AACT2::V1::AppAPI
      mount AACT2::V1::StudiesAPI
      add_swagger_documentation \
        doc_version: '0.0.2',
        hide_documentation_path: true,
        info: {
          title: "AACT API.",
          description: "REST API to the AACT Service.",
        }
    end
  end
end
