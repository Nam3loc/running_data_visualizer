module Api
  module Fitbit
    class DataController < ApplicationController
      before_action :authenticate_user!
      before_action :require_fitbit_connection

      def steps
        date = params[:date]
        return render json: { error: "Date parameter is required" }, status: :bad_request unless date

        begin
          data = FitbitClient.new(current_user).get_steps(date)
          render json: data
        rescue FitbitClient::Error => e
          handle_fitbit_error(e)
        end
      end

      def heart_rate
        date = params[:date]
        return render json: { error: "Date parameter is required" }, status: :bad_request unless date

        begin
          data = FitbitClient.new(current_user).get_heart_rate(date)
          render json: data
        rescue FitbitClient::Error => e
          handle_fitbit_error(e)
        end
      end

      def sleep
        date = params[:date]
        return render json: { error: "Date parameter is required" }, status: :bad_request unless date

        begin
          data = FitbitClient.new(current_user).get_sleep(date)
          render json: data
        rescue FitbitClient::Error => e
          handle_fitbit_error(e)
        end
      end

      private

      def require_fitbit_connection
        unless current_user.fitbit_token.present?
          render json: { error: "Fitbit account not connected" }, status: :unauthorized
        end
      end

      def handle_fitbit_error(error)
        case error.message
        when /Rate limit exceeded/
          render json: { error: error.message }, status: :too_many_requests
        when /Network error/
          render json: { error: error.message }, status: :service_unavailable
        else
          render json: { error: error.message }, status: :bad_request
        end
      end
    end
  end
end
