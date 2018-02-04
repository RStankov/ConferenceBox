# frozen_string_literal: true

require 'spec_helper'

describe Admin::PhotosController do
  stub_current_user

  describe 'GET index' do
    it 'assigns an event' do
      allow(Event).to receive(:find).with('1').and_return 'event'
      get :index, params: { event_id: 1 }
      expect(assigns[:event]).to eq 'event'
    end
  end

  describe 'POST create' do
    let(:photo) { { id: 1 } }

    before do
      allow(Photo).to receive(:create!).and_return photo
    end

    it 'creates a new photo' do
      post :create, params: { event_id: '1', file: 'file' }
      expect(Photo).to have_received(:create!).with(event_id: '1', asset: 'file')
    end

    it 'renders photo in json format' do
      post :create, params: { event_id: '1' }
      expect(controller).to render json: photo
    end
  end

  describe 'DELETE destroy' do
    it 'removes a photo' do
      allow(Photo).to receive(:destroy).with('1')
      delete :destroy, params: { event_id: '1', id: '1' }
      expect(Photo).to have_received(:destroy).with('1')
    end
  end

  describe 'PATCH reorder' do
    it 'reorders photos from the given event' do
      allow(Photo).to receive(:change_position_of).with %w(1 2 3), event_id: '1'
      patch :reorder, params: { event_id: '1', ids: %w(1 2 3) }
      expect(Photo).to have_received(:change_position_of).with %w(1 2 3), event_id: '1'
    end
  end
end
