# frozen_string_literal: true

class CfpController < ApplicationController
  def show
    @window = Cfp::WindowDecorator.decorate current_event.cfp_window if current_event.cfp_window
  end
end
