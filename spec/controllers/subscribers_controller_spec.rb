require 'spec_helper'

describe SubscribersController do
  stub_current_conference

  describe "POST 'create'" do
    let(:subscriber) { double 'Subscriber', valid?: true }

    before do
      allow(Subscriber).to receive(:subscribe).and_return subscriber
    end

    it "creates a new subscriber" do
      post :create, params: { subscriber: {email: 'email@example.org'} }
      expect(Subscriber).to have_received(:subscribe).with'email@example.org', current_conference
    end

    it "renders create action if subscriber is valid" do
      allow(subscriber).to receive(:valid?).and_return true
      post :create, params: { subscriber: {email: 'email@example.org'} }
      expect(controller).to render :create
    end

    it "renders new action if subscriber is not valid" do
      allow(subscriber).to receive(:valid?).and_return false
      post :create, params: { subscriber: {email: 'email@example.org'} }
      expect(controller).to render :new
    end
  end

  describe "GET 'destroy'" do
    it "unsubscribes email" do
      allow(Subscriber).to receive(:unsubscribe).with('token')

      get :destroy, params: { token: 'token' }

      expect(Subscriber).to have_received(:unsubscribe)
    end
  end
end
