# frozen_string_literal: true

require 'spec_helper'

describe Cfp::ProposalDetailsForm do
  let(:event) { create :event }
  let(:proposal) { create :draft_cfp_proposal, event: event }

  let(:valid_attributes) do
    { title: 'Talk', abstract: 'About', format: 'talk', level: 'beginner', track: 'Backend', duration_minutes: 30 }
  end

  before { create :cfp_window, event: event, tracks: "Backend\nFrontend" }

  def form(attributes = {})
    described_class.new proposal, valid_attributes.merge(attributes)
  end

  it 'prefills from the proposal' do
    proposal.update! title: 'Existing', duration_minutes: 45

    form = described_class.new proposal

    expect(form.title).to eq 'Existing'
    expect(form.duration_minutes).to eq 45
  end

  it 'is valid with the required fields' do
    expect(form).to be_valid
  end

  it 'requires title and abstract within limits' do
    expect(form(title: '')).to have_error_on :title
    expect(form(title: 'x' * 121)).to have_error_on :title
    expect(form(abstract: '')).to have_error_on :abstract
    expect(form(abstract: 'x' * 2001)).to have_error_on :abstract
  end

  it 'requires known format and level' do
    expect(form(format: 'keynote')).to have_error_on :format
    expect(form(format: nil)).to have_error_on :format
    expect(form(level: 'guru')).to have_error_on :level
  end

  it 'requires duration between 5 and 240 minutes' do
    expect(form(duration_minutes: 4)).to have_error_on :duration_minutes
    expect(form(duration_minutes: 241)).to have_error_on :duration_minutes
    expect(form(duration_minutes: 'long')).to have_error_on :duration_minutes
    expect(form(duration_minutes: 240)).to be_valid
  end

  it 'requires an offered track' do
    expect(form(track: 'Mobile')).to have_error_on :track, 'is not one of the offered tracks'
    expect(form(track: nil)).to have_error_on :track
  end

  it 'accepts any track when the window has none' do
    event.cfp_window.update! tracks: nil

    expect(form(track: 'Anything')).to be_valid
    expect(form(track: nil)).to be_valid
  end

  it 'exposes the offered tracks' do
    expect(form.tracks).to eq %w(Backend Frontend)
  end

  describe '#save' do
    it 'updates the proposal' do
      expect(form(outline: 'Outline', notes_for_reviewers: 'Notes').save).to be true

      expect(proposal.reload).to have_attributes(
        title: 'Talk',
        abstract: 'About',
        format: 'talk',
        level: 'beginner',
        track: 'Backend',
        duration_minutes: 30,
        outline: 'Outline',
        notes_for_reviewers: 'Notes',
      )
    end

    it 'does nothing when invalid' do
      expect(form(title: '').save).to be false
      expect(proposal.reload.title).to be_nil
    end
  end
end
