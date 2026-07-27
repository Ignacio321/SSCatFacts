# frozen_string_literal: true

module Api
  module V1
    class SessionsController < ApplicationController
      def show
        if current_user
          render json: { id: current_user.id, username: current_user.username }
        else
          render json: { error: 'Not authenticated' }, status: :unauthorized
        end
      end

      def create
        user = User.find_by('LOWER(username) = ?', params[:username]&.downcase)

        if user&.authenticate(params[:password])
          session[:user_id] = user.id
          render json: { id: user.id, username: user.username }
        else
          render json: { error: 'Invalid username or password' }, status: :unauthorized
        end
      end

      def destroy
        session.delete(:user_id)
        head :no_content
      end
    end
  end
end
