# frozen_string_literal: true

require 'spec_helper'

describe Cfp::PromoteToSession do
  let(:event) { create :event }
  let(:proposal) do
    create :accepted_cfp_proposal, event: event, title: 'Talk', abstract: 'About', track: 'Frontend', duration_minutes: 45
  end

  before { create :cfp_window, event: event, tracks: "Backend\nFrontend" }

  def upload(file)
    Rack::Test::UploadedFile.new Rails.root.join('spec/fixtures', file), 'image/jpeg'
  end

  it 'creates a session with placeholder slot derived from the duration' do
    session = described_class.call proposal

    expect(session).to have_attributes(
      event: event,
      title: 'Talk',
      description: 'About',
      track: 2,
      start_at: '09:00',
      end_at: '09:45',
    )
  end

  it 'defaults to track 1 when the track is unknown' do
    proposal.update! track: 'Mobile'

    expect(described_class.call(proposal).track).to eq 1
  end

  it 'links the session back to the proposal' do
    session = described_class.call proposal

    expect(proposal.reload.session).to eq session
    expect(proposal).to be_promoted
  end

  it 'creates speakers from proposal speakers' do
    proposal.speakers.first.update!(
      name: 'Jane',
      email: 'jane@example.org',
      company: 'ACME',
      bio: 'Bio',
      links: "https://jane.example\nhttps://github.com/jane",
    )

    session = described_class.call proposal

    speaker = session.speakers.first
    expect(speaker).to have_attributes(
      name: 'Jane',
      email: 'jane@example.org',
      company: 'ACME',
      description: 'Bio',
      personal_site: 'https://jane.example',
    )
  end

  it 'reuses an existing speaker by email without overwriting it' do
    existing = create :speaker, name: 'Jane Doe', email: 'jane@example.org'
    proposal.speakers.first.update! name: 'J. Doe', email: 'jane@example.org'

    session = described_class.call proposal

    expect(session.speakers).to eq [existing]
    expect(existing.reload.name).to eq 'Jane Doe'
    expect(Speaker.count).to eq 1
  end

  it 'links every speaker of the proposal' do
    proposal.speakers.create! name: 'Co', email: 'co@example.org'

    expect(described_class.call(proposal).speakers.count).to eq 2
  end

  it 'is idempotent' do
    session = described_class.call proposal

    expect(described_class.call(proposal)).to eq session
    expect(Session.count).to eq 1
  end

  it 'copies the confirmation photo and t-shirt size to new speakers' do
    proposal_speaker = proposal.speakers.first
    proposal_speaker.update! tshirt_size: 'M'
    proposal_speaker.photo.attach upload('speaker_photo.jpg')

    speaker = described_class.call(proposal).speakers.first

    expect(speaker.tshirt_size).to eq 'M'
    expect(speaker.photo.blob).to eq proposal_speaker.photo.blob
  end

  it 'keeps the photo of an existing speaker' do
    existing = create :speaker, email: proposal.speakers.first.email, tshirt_size: 'L'
    existing.photo.attach upload('photo_asset.jpg')
    original = existing.photo.blob
    proposal.speakers.first.update! tshirt_size: 'S'
    proposal.speakers.first.photo.attach upload('speaker_photo.jpg')

    described_class.call proposal

    expect(existing.reload.photo.blob).to eq original
    expect(existing.tshirt_size).to eq 'L'
  end

  it 'works for confirmed proposals' do
    proposal.update! status: 'confirmed'
    expect(described_class.call(proposal)).to be_persisted
  end

  it 'refuses proposals that are not accepted' do
    rejected = create :cfp_proposal, event: event, status: 'rejected'

    expect { described_class.call rejected }.to raise_error ArgumentError
    expect(Session.count).to eq 0
  end
end
