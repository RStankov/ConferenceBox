# frozen_string_literal: true

fixture = ->(name) { { io: Rails.root.join('spec/fixtures', name).open, filename: name } }

User.find_or_create_by!(email: 'admin@example.com') do |user|
  user.first_name = 'Admin'
  user.last_name = 'User'
  user.password = '12345'
  user.password_confirmation = '12345'
end

return if Conference.exists?

speakers = [
  { name: 'Ana Petrova', company: 'Bitwise Labs', company_site: 'https://bitwise.example.com',
    twitter_account: 'anapetrova', github_account: 'anapetrova',
    description: 'Ana builds **distributed systems** and talks about failure modes nobody plans for.' },
  { name: 'Boris Ivanov', company: 'Northline', company_site: 'https://northline.example.com',
    linkedin_account: 'borisivanov',
    description: 'Boris leads the platform team at Northline and writes about *developer experience*.' },
  { name: 'Clara Nguyen', company: 'Freelance', personal_site: 'https://clara.example.com',
    instagram_account: 'claradesigns', dribbble_account: 'clara',
    description: 'Clara is a product designer who moved from print to interfaces.' },
  { name: 'Dimitar Stoyanov', company: 'Conference Box', organizer: true,
    twitter_account: 'dstoyanov', description: 'Dimitar organizes the conference and keeps the Wi-Fi running.' },
  { name: 'Elena Marinova', company: 'Datapath', company_site: 'https://datapath.example.com',
    github_account: 'elenam', description: 'Elena works on query engines and has opinions about SQL.' },
  { name: 'Filip Hristov', company: 'Open Source', github_account: 'fhristov',
    description: 'Filip maintains a handful of Ruby gems you probably depend on.' },
].map { Speaker.create!(_1) }

speakers.first(3).each { _1.photo.attach(fixture.call('speaker_photo.jpg')) }

sponsors = [
  { name: 'Bitwise Labs', website_url: 'https://bitwise.example.com' },
  { name: 'Northline', website_url: 'https://northline.example.com' },
  { name: 'Datapath', website_url: 'https://datapath.example.com' },
].map { Sponsor.create!(_1) }

sponsors.first.logo.attach(fixture.call('event_logo.png'))

conference = Conference.create!(
  name: 'DevConf Sofia',
  slogan: 'A one-day conference for people who build software',
  contact_name: 'Dimitar Stoyanov',
  contact_email: 'hello@devconf.example.com',
  domain: 'localhost',
  theme: 'it_tour',
  main: true,
  about: "DevConf Sofia gathers developers, designers and curious people for a day of talks.\n\n" \
         'Everything is single track, so nobody misses anything.',
  copyright: 'DevConf Sofia',
  facebook_account: 'devconfsofia',
  twitter_account: 'devconfsofia',
  instagram_account: 'devconfsofia',
  youtube_account: 'devconfsofia',
  code_of_conduct_url: 'https://devconf.example.com/code-of-conduct',
)

venue = {
  venue_name: 'Sofia Tech Park',
  venue_address: '111 Tsarigradsko Shose Blvd, Sofia',
  venue_site_url: 'https://sofiatech.example.com',
  venue_map_url: 'https://maps.example.com/sofia-tech-park',
  venue_map_embedded_url: 'https://maps.example.com/embed/sofia-tech-park',
  venue_notes: 'Parking is free. Enter through the main lobby of the Incubator building.',
  after_party_venue_name: 'The Bar Near The Park',
  after_party_venue_address: '12 Shipchenski Prohod St, Sofia',
  after_party_venue_site_url: 'https://thebar.example.com',
  after_party_venue_map_url: 'https://maps.example.com/the-bar',
  after_party_venue_map_embedded_url: 'https://maps.example.com/embed/the-bar',
  after_party_venue_notes: 'First drink is on the sponsors.',
}

announced = {
  publicly_announced: true,
  dates_announced: true,
  venue_announced: true,
  sessions_announced: true,
  speakers_announced: true,
  sponsors_announced: true,
  after_party_announced: true,
}

past_event = conference.events.create!(
  **venue, **announced,
  name: '2025',
  date: Date.new(2025, 5, 17),
  town: 'Sofia',
  color: '#1b6ac9',
  show_photo_gallery: true,
  show_feedback_form: true,
  sponsors: sponsors.first(2),
)

current_event = conference.events.create!(
  **venue, **announced,
  name: '2026',
  date: 3.weeks.from_now.to_date,
  town: 'Sofia',
  color: '#c92a1b',
  current: true,
  show_feedback_form: true,
  show_coverart: true,
  tickets_url: 'https://tickets.example.com/devconf-2026',
  event_url: 'https://devconf.example.com/2026',
  streaming_code: '<iframe src="https://stream.example.com/devconf" width="100%" height="480"></iframe>',
  notes: 'Internal notes: confirm catering numbers two weeks before the event.',
  sponsors: sponsors,
)

conference.events.create!(
  name: '2027',
  date: Date.new(2027, 5, 15),
  town: 'Sofia',
  publicly_announced: false,
  call_to_papers_url: 'https://cfp.example.com/devconf-2027',
)

current_event.logo.attach(fixture.call('event_logo.png'))
current_event.coverart.attach(fixture.call('event_coverart.jpg'))
past_event.logo.attach(fixture.call('event_logo.png'))

schedule = [
  ['09:00', '09:30', 'Registration and coffee', [], nil],
  ['09:30', '09:45', 'Opening', [speakers[3]], nil],
  ['09:45', '10:30', 'What breaks first: a field guide to distributed failures', [speakers[0]],
   'A tour of the outages we caused and what each one taught us about timeouts, retries and backpressure.'],
  ['10:45', '11:30', 'Developer experience is a product', [speakers[1]],
   'How we run the internal platform like a product team, with users, roadmaps and churn.'],
  ['11:45', '12:30', 'Designing for people who are busy', [speakers[2]],
   'Interfaces for people who have twelve other things to do right now.'],
  ['12:30', '13:30', 'Lunch', [], nil],
  ['13:30', '14:15', 'Your query planner is smarter than you', [speakers[4]],
   'Reading EXPLAIN output without crying, and when to stop fighting the planner.'],
  ['14:30', '15:15', 'Maintaining open source without burning out', [speakers[5], speakers[0]],
   'A conversation about saying no, saying yes and handing things over.'],
  ['15:30', '16:00', 'Closing and raffle', [speakers[3]], nil],
]

[past_event, current_event].each do |event|
  schedule.each do |start_at, end_at, title, session_speakers, description|
    session = event.sessions.create!(
      start_at: start_at, end_at: end_at, title: title, description: description, speakers: session_speakers,
    )
    next unless event == past_event && session_speakers.any?

    session.update!(
      slides_url: "https://slides.example.com/devconf-2025/#{title.parameterize}",
      video_url: "https://videos.example.com/devconf-2025/#{title.parameterize}",
    )
  end
end

12.times { past_event.photos.create!(asset: fixture.call('photo_asset.jpg')) }

[
  'Great talks, the venue was a bit cold though.',
  'Loved the single track format. More time for questions would be nice.',
  'The after party was the best part.',
].each { past_event.feedbacks.create!(comment: _1) }

Conference.create!(
  name: 'Design Day',
  slogan: 'One afternoon about design',
  contact_name: 'Clara Nguyen',
  contact_email: 'hello@designday.example.com',
  domain: 'designday.example.com',
  theme: 'plain',
  copyright: 'Design Day',
).events.create!(
  **announced,
  name: '2026',
  date: 6.weeks.from_now.to_date,
  town: 'Plovdiv',
  current: true,
  venue_name: 'Plovdiv Creative Hub',
  venue_address: '5 Otets Paisiy St, Plovdiv',
  sponsors: sponsors.last(1),
).sessions.create!(start_at: '14:00', end_at: '14:45', title: 'Why print still matters', speakers: [speakers[2]])
