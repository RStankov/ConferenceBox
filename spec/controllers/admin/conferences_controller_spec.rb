# frozen_string_literal: true

require 'spec_helper'

describe Admin::ConferencesController do
  stub_current_user

  let(:conference) { instance_double Conference }

  describe 'GET index' do
    it 'assigns all conferences' do
      allow(Conference).to receive(:all).and_return [conference]
      get :index
      expect(assigns[:conferences]).to eq [conference]
    end
  end

  describe 'GET new' do
    it 'assigns new conference' do
      allow(Conference).to receive(:new).and_return conference
      get :new
      expect(assigns[:conference]).to eq conference
    end
  end

  describe 'POST create' do
    before do
      allow(Conference).to receive(:create).with('name' => 'VarnaConf').and_return conference
    end

    it 'creates a new conference' do
      post :create, params: { conference: { name: 'VarnaConf' } }
      expect(Conference).to have_received(:create).with('name' => 'VarnaConf')
    end

    it 'assigns the new conference' do
      post :create, params: { conference: { name: 'VarnaConf' } }
      expect(assigns[:conference]).to eq conference
    end

    it 'responds with the new conference' do
      post :create, params: { conference: { name: 'VarnaConf' } }
      expect(controller).to respond_with conference, location: admin_conferences_path
    end
  end

  describe 'GET show' do
    it 'redirect to conference events' do
      get :show, params: { id: '1' }
      expect(controller).to redirect_to admin_conference_events_path('1')
    end
  end

  describe 'GET edit' do
    it 'assigns the conference' do
      allow(Conference).to receive(:find).with('1').and_return conference
      get :edit, params: { id: '1' }
      expect(assigns[:conference]).to eq conference
    end
  end

  describe 'PATCH update' do
    before do
      allow(Conference).to receive(:update).with('1', 'name' => 'VarnaConf').and_return conference
    end

    it 'updates the conference' do
      patch :update, params: { id: '1', conference: { name: 'VarnaConf' } }
      expect(Conference).to have_received(:update).with('1', 'name' => 'VarnaConf')
    end

    it 'assigns the conference' do
      patch :update, params: { id: '1', conference: { name: 'VarnaConf' } }
      expect(assigns[:conference]).to eq conference
    end

    it 'responds with the conference' do
      patch :update, params: { id: '1', conference: { name: 'VarnaConf' } }
      expect(controller).to respond_with conference, location: admin_conferences_path
    end
  end

  describe 'DELETE destroy' do
    before do
      allow(Conference).to receive(:destroy).with('1').and_return conference
    end

    it 'removes the conference' do
      delete :destroy, params: { id: '1' }
      expect(Conference).to have_received(:destroy).with('1')
    end

    it 'redirects to conferences list' do
      delete :destroy, params: { id: '1' }
      expect(controller).to respond_with conference, location: admin_conferences_path
    end
  end
end
