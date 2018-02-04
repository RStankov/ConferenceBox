require 'spec_helper'

describe SchedulesController do
  stub_current_conference

  let(:event) { double name: '2015' }

  describe "GET 'index'" do
    it 'redirects to current event schedule' do
      allow(current_conference).to receive(:current_event).and_return event

      get :index

      expect(controller).to redirect_to schedule_path(event.name, format: 'json')
    end
  end

  describe "GET 'show'" do
    before do
      allow(current_conference).to receive(:announced_event_named).with(event.name).and_return event
    end

    it 'assigns event' do
      get :show, params: { id: event.name }, format: :json

      expect(assigns[:event]).to eq event
    end

    it 'redirects when format is not json' do
      get :show, params: { id: event.name }

      expect(controller).to redirect_to schedule_path(event.name, format: 'json')
    end
  end
end
