# frozen_string_literal: true

class ConferencesController < ApplicationController
  def show
    if current_conference.main?
      @conference = current_conference
      render 'conferences/show'
    else
      @event = current_event
      render 'events/show'
    end
  end
end
