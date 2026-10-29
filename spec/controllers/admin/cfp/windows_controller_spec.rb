# frozen_string_literal: true

require 'spec_helper'

describe Admin::Cfp::WindowsController do
  stub_current_user

  let(:event) { instance_double Event, to_param: '1' }
  let(:window) { instance_double Cfp::Window }

  before do
    allow(Event).to receive(:find).with('1').and_return event
  end

  describe 'GET new' do
    it 'builds a window for the event' do
      allow(event).to receive(:build_cfp_window).and_return window
      get :new, params: { event_id: '1' }
      expect(assigns[:event]).to eq event
      expect(assigns[:window]).to eq window
    end
  end

  describe 'POST create' do
    before do
      allow(event).to receive(:create_cfp_window).with(permitted_params(tracks: 'Backend')).and_return window
    end

    it 'creates the window' do
      post :create, params: { event_id: '1', cfp_window: { tracks: 'Backend' } }
      expect(event).to have_received(:create_cfp_window).with(permitted_params(tracks: 'Backend'))
    end

    it 'responds with the window' do
      post :create, params: { event_id: '1', cfp_window: { tracks: 'Backend' } }
      expect(controller).to respond_with window, location: admin_event_path('1')
    end
  end

  describe 'GET edit' do
    it 'assigns the window' do
      allow(event).to receive(:cfp_window).and_return window
      get :edit, params: { event_id: '1' }
      expect(assigns[:window]).to eq window
    end
  end

  describe 'PATCH update' do
    before do
      allow(event).to receive(:cfp_window).and_return window
      allow(window).to receive(:update).and_return true
    end

    it 'updates the window' do
      patch :update, params: { event_id: '1', cfp_window: { tracks: 'Backend' } }
      expect(window).to have_received(:update).with(permitted_params(tracks: 'Backend'))
    end

    it 'responds with the window' do
      patch :update, params: { event_id: '1', cfp_window: { tracks: 'Backend' } }
      expect(controller).to respond_with window, location: admin_event_path('1')
    end
  end

  describe 'DELETE destroy' do
    it 'destroys the window' do
      allow(event).to receive(:cfp_window).and_return window
      allow(window).to receive(:destroy).and_return window
      delete :destroy, params: { event_id: '1' }
      expect(window).to have_received(:destroy)
      expect(controller).to respond_with window, location: admin_event_path('1')
    end
  end
end
