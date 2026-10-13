# frozen_string_literal: true

namespace :cfp do
  desc 'Moves proposals of closed call for papers windows into review. Run it from a scheduler once a day.'
  task close_windows: :environment do
    Cfp::CloseWindowsJob.perform_now
  end
end
