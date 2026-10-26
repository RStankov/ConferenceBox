# frozen_string_literal: true

require 'spec_helper'

describe Cfp::ConfirmationForm do
  let(:proposal) { create :accepted_cfp_proposal, speaker_name: 'Jane' }
  let(:speaker) { proposal.speakers.first }

  def photo(file = 'speaker_photo.jpg', type = 'image/jpeg')
    Rack::Test::UploadedFile.new Rails.root.join('spec/fixtures', file), type
  end

  def form_with(details)
    described_class.new proposal, speakers: { speaker.id.to_s => details }
  end

  it 'confirms the proposal and stores photo and t-shirt size' do
    form = form_with photo: photo, tshirt_size: 'M'

    expect(form.save).to be true
    expect(proposal.reload).to be_confirmed
    expect(speaker.reload.tshirt_size).to eq 'M'
    expect(speaker.photo).to be_attached
    expect(proposal.status_changes.last.note).to eq 'Confirmed by the speaker'
  end

  it 'requires a photo and a t-shirt size for every speaker' do
    form = form_with({})

    expect(form.save).to be false
    expect(form.errors.full_messages).to eq ['Jane: add a photo for the program', 'Jane: pick a t-shirt size']
    expect(proposal.reload).to be_accepted
  end

  it 'keeps a photo uploaded earlier' do
    speaker.photo.attach photo

    expect(form_with(tshirt_size: 'L').save).to be true
  end

  it 'rejects files that are not images' do
    form = form_with photo: photo('speaker_photo.jpg', 'application/pdf'), tshirt_size: 'M'

    expect(form.save).to be false
    expect(form.errors.full_messages).to eq ['Jane: the photo must be a JPEG, PNG or WebP image']
  end

  it 'rejects unknown t-shirt sizes' do
    form = form_with photo: photo, tshirt_size: 'XXXL'

    expect(form.save).to be false
    expect(form.errors.full_messages).to eq ['Jane: pick a t-shirt size']
  end

  it 'refuses proposals that are not accepted' do
    proposal.update! status: 'rejected'

    form = form_with photo: photo, tshirt_size: 'M'

    expect(form.save).to be false
    expect(form.errors.full_messages).to include 'Only accepted proposals can be confirmed'
  end
end
