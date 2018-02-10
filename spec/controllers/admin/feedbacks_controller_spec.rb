# frozen_string_literal: true

require 'spec_helper'

describe Admin::FeedbacksController do
  stub_current_user

  describe 'GET index' do
    let(:event) { instance_double Event }

    before do
      feedback_double = class_double(Feedback, newest: class_double(Feedback, page: 'feedbacks'))
      allow(Event).to receive(:find).with('1').and_return event
      allow(event).to receive(:feedbacks).and_return feedback_double
    end

    it 'assigns selected event' do
      get :index, params: { event_id: 1 }
      expect(assigns[:event]).to eq event
    end

    it 'assigns paginaged feedbacks' do
      get :index, params: { event_id: 1 }
      expect(assigns[:feedbacks]).to eq 'feedbacks'
    end
  end

  describe 'DELETE destroy' do
    before do
      allow(Feedback).to receive(:destroy).with('1').and_return instance_double(Feedback, event_id: '2')
    end

    it 'removes the feedback' do
      delete :destroy, params: { id: '1' }
      expect(Feedback).to have_received(:destroy).with('1')
    end

    it 'redirects to feedbacks list' do
      delete :destroy, params: { id: '1' }
      expect(controller).to redirect_to admin_event_feedbacks_path(event_id: '2')
    end
  end
end
