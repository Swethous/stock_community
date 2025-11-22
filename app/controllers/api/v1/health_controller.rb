class Api::V1::HealthController < ApplicationController
  def index
    render json: { status: "ok", time: Time.current }
  end
end