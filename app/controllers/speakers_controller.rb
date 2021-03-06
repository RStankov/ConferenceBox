# frozen_string_literal: true

class SpeakersController < ApplicationController
  def show
    @speaker = SpeakerDecorator.decorate Speaker.find(params[:id])
    respond_with @speaker
  end
end
