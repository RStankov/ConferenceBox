# frozen_string_literal: true

require 'spec_helper'

describe ConferencesController do
  stub_current_conference

  describe '#show' do
    context 'when regular conference' do
      before do
        allow(current_conference).to receive(:current_event).and_return 'event'
        allow(current_conference).to receive(:main?).and_return false

        allow(EventDecorator).to receive(:decorate).with('event').and_return 'decorated event'
      end

      it 'assigns decorated event' do
        get :show
        expect(assigns[:event]).to eq 'decorated event'
      end

      it 'renders "event/show" action' do
        get :show
        expect(controller).to render 'events/show'
      end
    end

    context 'when main conference' do
      before do
        allow(current_conference).to receive(:main?).and_return true
      end

      it 'assigns the current conference as @conference' do
        get :show
        expect(assigns[:conference]).to eq current_conference
      end

      it 'doesnt assigns current event' do
        get :show
        expect(assigns[:events]).to be_nil
      end

      it 'renders show action' do
        get :show
        expect(controller).to render 'conferences/show'
      end
    end
  end
end
