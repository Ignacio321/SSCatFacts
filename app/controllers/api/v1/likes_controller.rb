# frozen_string_literal: true

module Api
  module V1
    class LikesController < ApplicationController
      before_action :require_authentication!

      def create
        like = current_user.likes.find_or_create_by!(fact: find_or_create_fact)

        render json: like_json(like), status: like.previously_new_record? ? :created : :ok
      rescue ActiveRecord::RecordInvalid => e
        render json: { errors: e.record.errors.full_messages }, status: :unprocessable_content
      end

      def destroy
        like = current_user.likes.find(params.expect(:id))
        like.destroy!
        head :no_content
      end

      private

      def find_or_create_fact
        Fact.find_or_create_by!(text: fact_params[:text]) { |f| f.length = fact_params[:length] }
      end

      def fact_params
        params.expect(fact: %i[text length])
      end

      def like_json(like)
        { id: like.id, fact: { text: like.fact.text, length: like.fact.length } }
      end
    end
  end
end
