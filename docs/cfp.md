# Call for papers

ConferenceBox can run the call for papers (CFP) of an event in-app instead of linking to an external form. Speakers submit proposals without an account, reviewers score them, organizers decide and accepted proposals become sessions in the schedule.

## Roles

| Role        | Can do                                                                 |
|-------------|------------------------------------------------------------------------|
| `admin`     | Everything, including changing roles on the Team page                  |
| `organizer` | Manage events, run the CFP, assign reviewers, decide, promote, export  |
| `reviewer`  | Only the review queue: score assigned proposals and join the discussion |

Existing users were backfilled as `admin`. New users default to `admin` too, so demote reviewers from `/admin/team_members`.

## Setting up a window

Every event can have one `Cfp::Window` (`/admin/events/:id/cfp/window`). It holds the open and close times, the tracks (one per line), the markdown guidelines, the per-speaker submission limit and the blind review flag.

The public landing page at `/cfp` reflects the window state. The event decorator prefers the in-app CFP over `call_to_papers_url`, which stays as a fallback for conferences that still use an external form.

## Proposal lifecycle

```mermaid
stateDiagram-v2
    [*] --> draft: speaker starts a submission
    draft --> submitted: speaker submits
    draft --> withdrawn: window closes before submission
    submitted --> under_review: reviewer assigned or window closes
    submitted --> withdrawn: speaker withdraws
    submitted --> accepted
    submitted --> rejected
    submitted --> waitlisted
    under_review --> accepted: organizer decides
    under_review --> rejected: organizer decides
    under_review --> waitlisted: organizer decides
    under_review --> withdrawn: speaker withdraws
    waitlisted --> accepted
    waitlisted --> rejected
    waitlisted --> withdrawn
    accepted --> confirmed: speaker confirms with photos and t-shirt sizes
    accepted --> declined: speaker declines with an optional note
    rejected --> [*]
    confirmed --> [*]
    declined --> [*]
    withdrawn --> [*]
```

All transitions go through `Cfp::StateMachine.transition`, which validates the move, stamps `submitted_at` / `decided_at` and writes a `Cfp::StatusChange` row for the audit timeline. Anything else raises `Cfp::InvalidTransition`.

## From submission to the schedule

```mermaid
sequenceDiagram
    actor Speaker
    participant Public as /cfp/submissions
    participant Mailer as Cfp::ProposalMailer
    actor Organizer
    participant Admin as /admin/events/:id/cfp
    actor Reviewer
    participant Queue as /admin/cfp/reviews

    Speaker->>Public: step 1, speaker details
    Public->>Public: Cfp::SpeakerDetailsForm creates a draft proposal
    Speaker->>Public: step 2, proposal details
    Public->>Public: Cfp::ProposalDetailsForm validates and saves
    Speaker->>Public: step 3, submit
    Public->>Mailer: received(proposal)
    Mailer-->>Speaker: private magic link (token)

    Organizer->>Admin: auto-assign reviewers
    Admin->>Admin: Cfp::AssignReviewers balances load, skips conflicts
    Reviewer->>Queue: score, confidence, comment
    Reviewer->>Queue: or flag a conflict of interest

    Organizer->>Admin: filter and sort by score
    Admin->>Admin: Cfp::ScoreAggregation (mean, median, variance)
    Organizer->>Admin: accept / reject / waitlist (single or bulk)
    Admin->>Admin: Cfp::DecideProposals
    Organizer->>Admin: send decision emails
    Admin->>Mailer: Cfp::SendDecisionsJob renders the template per speaker
    Mailer-->>Speaker: decision with the confirmation link

    Speaker->>Public: confirm, upload photos, pick t-shirt sizes
    Public->>Public: Cfp::ConfirmationForm moves the proposal to confirmed

    Organizer->>Admin: promote to session
    Admin->>Admin: Cfp::PromoteToSession creates Session + Speaker with the photo
```

### Submissions

- No account is needed. The proposal token is the only credential, the confirmation email carries the link.
- Speakers can edit or withdraw while the window is open and the proposal is `draft` or `submitted`.
- `max_submissions_per_speaker` is enforced by email, withdrawn proposals do not count.

### Reviews

- Reviewers see only assignments without a conflict flag, on proposals that are still `submitted` or `under_review`.
- With `blind_review` on, reviewers do not see speaker names, emails, companies or bios. Organizers always see them.
- Each reviewer gives a score from 1 (strong reject) to 5 (strong accept) and a confidence from 1 to 3. One review per reviewer per proposal, editable until the decision.
- The internal discussion thread is visible to the whole team and never to the speaker.

### Decisions and emails

- Decisions can be taken from the proposal page or in bulk from the proposals table with an optional note for the timeline.
- Decision emails use an editable template with `{{speaker_name}}`, `{{proposal_title}}` and `{{event_name}}` placeholders, previewed against a real proposal before sending.
- `Cfp::SendDecisionsJob` marks `decision_sent_at` after each email, so re-running it only reaches speakers who have not been emailed yet.

### Speaker confirmation

Accepted proposals wait for the speakers to confirm. The accepted decision email carries a `{{confirmation_url}}` placeholder that points to `/cfp/submissions/:token/confirmation`, and the proposal page links there too.

```mermaid
flowchart LR
    email[Decision email] --> page[Confirmation page]
    page --> valid{Every speaker has a photo and a t-shirt size?}
    valid -- no --> page
    valid -- yes --> confirmed([confirmed])
    page -- decline --> declined([declined])
    confirmed --> promote[Promote to session]
    promote --> speaker[Speaker record with photo]
```

- One form covers every speaker on the proposal: a photo (JPEG, PNG or WebP up to 5 MB) and a t-shirt size each. A photo uploaded earlier is kept when the field is left empty.
- Confirming or declining stamps `responded_at` and writes a timeline entry. A decline note from the speaker is stored as the timeline note.
- The admin proposal page shows the photos, t-shirt sizes and when the speaker responded, or that the decision went out and the confirmation is pending.
- Themes fall back to `cfp/speaker-placeholder.svg` for speakers without a photo.

### Promotion

`Cfp::PromoteToSession` creates a `Session` with the proposal title, abstract, track number (position of the track in the window's track list) and a placeholder `09:00` slot sized by the proposal duration. Speakers are matched by email to existing `Speaker` records, or created with the name, company, bio and first link from the proposal. The confirmation photo and t-shirt size are copied over unless the speaker already has them. Promotion is idempotent.

## Background jobs and scheduled tasks

| Job                         | Trigger                                   | What it does                                                           |
|-----------------------------|-------------------------------------------|------------------------------------------------------------------------|
| `Cfp::CloseWindowsJob`      | `rake cfp:close_windows` from a scheduler | Withdraws drafts and moves submitted proposals to review once closed   |
| `Cfp::ReviewerReminderJob`  | "Remind reviewers" button                 | Emails each reviewer the number of pending assignments                 |
| `Cfp::SendDecisionsJob`     | Decision emails screen                    | Sends the templated decision to every proposal in the selected status  |

## Exports

The proposals table and the review queue both export CSV through `Cfp::ProposalsCsv`, including speaker details and the aggregated scores.
