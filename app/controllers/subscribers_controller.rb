# frozen_string_literal: true

class SubscribersController < ApplicationController
  def new
  end

  def create
    @subscriber = Subscriber.subscribe email_param, current_conference

    if @subscriber.valid?
      render :create
    else
      render :new
    end
  end

  def destroy
    Subscriber.unsubscribe params[:token]
  end

  private

  def email_param
    return unless params[:subscriber]
    params[:subscriber][:email]
  end
end
