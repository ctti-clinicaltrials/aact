module AACT2
  module V1
    class AppAPI < Grape::API
      desc 'app status' do
        detail 'this returns a health status'
        named 'app_storage'
        failure [
          [200,'Database functional, and seeded correctly'],
          [503, 'database not seeded, or not functional']
        ]
      end
      get '/app/status', root: false do
        status = {status: 'ok', environment: "#{Rails.env}", rdbms: 'ok', keystore: 'ok'}
        begin
          #rdbms must be connected
          unless ActiveRecord::Base.connection.active?
            status[:status] = 'error'
            status[:rdbms] = 'is not connected'
          end

          #redis must be configured and connected in Sidekiq
          Sidekiq.redis do |conn|
            unless conn.info
            end
          end

          if status[:status] == 'ok'
            status
          else
            error!(status,503)
          end
        rescue SocketError => e
          status[:status] = 'error'
          status[:keystore] = 'is not connected'
          error!(status,503)
        rescue Exception => e
          logger.error("GOT UNKOWNN Exception "+e.inspect)
          status[:status] = 'error'
          error!(status,503)
        end
      end
    end
  end
end
