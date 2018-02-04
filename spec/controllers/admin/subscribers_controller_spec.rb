require 'spec_helper'

describe Admin::SubscribersController do
  stub_current_user

  let(:subscriber) { double :subscriber, conference_id: '2' }

  describe "GET index" do
    it "assign filtered subscribers list" do
      allow(Subscriber).to receive(:filter).with({'key' => 'value'}).and_return [subscriber]
      get :index, params: { filter: {key: 'value'} }
      expect(assigns[:subscribers]).to eq [subscriber]
    end
  end

  describe "POST create" do
    before do
      allow(Subscriber).to receive(:create).and_return subscriber
      allow(subscriber).to receive(:error_message).and_return nil
    end

    it "creates a new subscriber" do
      post :create, params: { subscriber: {email: 'address'} }

      expect(Subscriber).to have_received(:create).with('email' => 'address')
    end

    it "assigns the new subscriber" do
      post :create, params: { subscriber: {some: 'attributes'} }
      expect(assigns[:subscriber]).to eq subscriber
    end

    it "sets the flash alert to subscriber error message (if some)" do
      allow(subscriber).to receive(:error_message).and_return 'Error message'
      post :create, params: { subscriber: {some: 'attributes'} }
      expect(flash[:alert]).to eq 'Error message'
    end

    it "redirects to admin conference subscribers list" do
      post :create, params: { subscriber: {some: 'attributes'} }
      expect(controller).to redirect_to admin_subscribers_path(conference_id: '2')
    end
  end

  describe "PATCH update" do
    before do
      allow(Subscriber).to receive(:update).and_return subscriber
      allow(subscriber).to receive(:error_message).and_return nil
    end

    it "updates the subscriber" do
      patch :update, params: { id: 1, subscriber: {email: 'address'} }
      expect(Subscriber).to have_received(:update).with('1', 'email' => 'address')
    end

    it "assigns the subscriber" do
      patch :update, params: { id: 1, subscriber: {some: 'attributes'} }
      expect(assigns[:subscriber]).to eq subscriber
    end

    it "sets the flash alert to subscriber error message (if some)" do
      allow(subscriber).to receive(:error_message).and_return 'Error message'
      patch :update, params: { id: 1, subscriber: {some: 'attributes'} }
      expect(flash[:alert]).to eq 'Error message'
    end

    it "redirects to admin conference subscribers list" do
      patch :update, params: { id: 1, subscriber: {some: 'attributes'} }
      expect(controller).to redirect_to admin_subscribers_path(conference_id: '2')
    end
  end

  describe "DELETE destroy" do
    before do
      allow(Subscriber).to receive(:destroy).with('1').and_return subscriber
    end

    it "removes the subscriber" do
      delete :destroy, params: { id: '1' }
      expect(Subscriber).to have_received(:destroy).with('1')
    end

    it "redirects to subscribers list" do
      delete :destroy, params: { id: '1' }
      expect(controller).to redirect_to admin_subscribers_path(conference_id: '2')
    end
  end
end



