# frozen_string_literal: true

require 'spec_helper'

describe CfpController do
  stub_current_conference

  let(:event) { build :event }

  before do
    allow(controller).to receive(:current_event).and_return EventDecorator.decorate(event)
  end

  describe 'GET show' do
    it 'assigns a decorated window when the event has one' do
      window = build :cfp_window, event: event
      event.cfp_window = window
      get :show
      expect(assigns[:window]).to be_a Cfp::WindowDecorator
      expect(assigns[:window].object).to eq window
    end

    it 'assigns nothing when the event has no window' do
      get :show
      expect(assigns[:window]).to be_nil
    end
  end
end
