# frozen_string_literal: true

require 'spec_helper'

describe Photo do
  describe '#change_position_of' do
    it 'reorders photos in the given order' do
      photo1 = create :photo
      photo2 = create :photo
      photo3 = create :photo

      ids = [photo2, photo3, photo1].map(&:id)

      described_class.change_position_of ids

      expect(described_class.ordered.pluck(:id)).to eq ids
    end

    it 'can scope the photos' do
      photo1 = create :photo
      photo2 = create :photo, position: 2

      described_class.change_position_of [photo1, photo2].map(&:id), event_id: photo1.event_id

      expect(described_class.ordered.pluck(:id)).to eq [photo2, photo1].map(&:id)
    end

    it 'can work with no ids' do
      expect { described_class.change_position_of nil }.not_to raise_error
    end
  end

  describe '#position' do
    it 'is set to previous photo + 1 on creation' do
      event = create :event

      photo1 = create :photo, event: event
      photo2 = create :photo, event: event

      expect(photo1.position).to eq 1
      expect(photo2.position).to eq 2
    end

    it 'is decreased when photo from event is removed' do
      event = create :event

      photo1 = create :photo, event: event, position: 1
      photo2 = create :photo, event: event, position: 2
      photo3 = create :photo, event: event, position: 3

      photo2.destroy

      expect(photo1.reload.position).to eq 1
      expect(photo3.reload.position).to eq 2
    end

    it 'doesnt care about photos from other events' do
      photo = create :photo
      other = create :photo

      expect(photo.position).to eq 1
      expect(other.position).to eq 1
    end

    it 'can be overwritten' do
      photo = create :photo, position: 100
      expect(photo.position).to eq 100
    end
  end
end
