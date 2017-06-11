PollGenerator = Struct.new(:poll_type) do

  def generate!
    return unless Poll::TEMPLATES.keys.include?(poll_type.to_s)
    poll = Poll.create(default_params)
    poll.community_of_type(:email, build: true)
    poll.save!
    send(:"#{poll_type}_stances_for", poll)
    poll.update_stance_data
    poll.community_of_type(:email).visitors.create(email: User.demo_bot.email)
    poll
  end

  private

  def default_params
    {
      poll_type:               poll_type,
      author:                  User.helper_bot,
      title:                   I18n.t(:"poll_generator.#{poll_type}.title"),
      details:                 I18n.t(:"poll_generator.#{poll_type}.details"),
      poll_options_attributes: Poll::TEMPLATES.dig(poll_type, 'poll_options_attributes'),
      closing_at:              1.day.from_now,
      example:                 true
    }.merge(send(:"#{poll_type}_params"))
  end

  def proposal_params
    {}
  end

  def proposal_stances_for(poll)
    generate_stance_for(poll, reason: "I love them, and think they'll both be great!", choice: "agree")
    generate_stance_for(poll, reason: "Solid additions", choice: "agree")
    generate_stance_for(poll, reason: "100% agree, they're awesome.", choice: "agree")
    generate_stance_for(poll, reason: "I love them, and think they'll both be great!", choice: "agree")
    generate_stance_for(poll, reason: "I haven't really interacted with either, but I trust the team", choice: "abstain")
    generate_stance_for(poll, reason: "I'd feel more comfortable if we kept them as interns for another month or so", choice: "disagree")
  end

  def count_params
    {}
  end

  def count_stances_for(poll)
    generate_stance_for(poll, reason: "", choice: "yes")
    generate_stance_for(poll, reason: "I would love to help, but I'll be on vacation for the week before", choice: "no")
    generate_stance_for(poll, reason: "I'd love to help!", choice: "yes")
    generate_stance_for(poll, reason: "Sorry, not me.. too busy at the moment", choice: "no")
    generate_stance_for(poll, reason: "Yes!", choice: "yes")
    generate_stance_for(poll, reason: "Happy to help :)", choice: "yes")
  end

  def poll_params
    {
      poll_option_names: ["No gluten for me", "I can't eat meat", "I'm allergic to shellfish", "I'll eat anything!"],
      multiple_choice: true
    }
  end

  def poll_stances_for(poll)
    generate_stance_for(poll, reason: "", choice: "No gluten for me")
    generate_stance_for(poll, reason: "Looking forward to it!", choice: "No gluten for me")
    generate_stance_for(poll, reason: "", choice: "No gluten for me")
    generate_stance_for(poll, reason: "See you then!", choice: "I'm allergic to shellfish")
    generate_stance_for(poll, reason: "", choice: "I'll eat anything!")
    generate_stance_for(poll, reason: "", choice: "")
  end

  def dot_vote_params
    {
      poll_option_names: ["Product development", "Customer acquisition", "Customer support", "Enterprise Sales", "Team growth"],
      custom_fields: { dots_per_person: 8 }
    }
  end

  def dot_vote_stances_for(poll)
    generate_stance_for(poll, reason: "", stance_choices_attributes: [
      { poll_option_id: poll.poll_option_ids[1], score: 2 },
      { poll_option_id: poll.poll_option_ids[2], score: 3 },
      { poll_option_id: poll.poll_option_ids[3], score: 3 }
    ])
    generate_stance_for(poll, reason: "", stance_choices_attributes: [
      { poll_option_id: poll.poll_option_ids[0], score: 7 },
      { poll_option_id: poll.poll_option_ids[4], score: 1 }
    ])
    generate_stance_for(poll, reason: "", stance_choices_attributes: [
      { poll_option_id: poll.poll_option_ids[0], score: 1 },
      { poll_option_id: poll.poll_option_ids[1], score: 3 },
      { poll_option_id: poll.poll_option_ids[2], score: 1 },
      { poll_option_id: poll.poll_option_ids[3], score: 1 },
      { poll_option_id: poll.poll_option_ids[4], score: 2 }
    ])
  end

  def meeting_params
    {
      poll_option_names: [
        2.days.from_now.beginning_of_hour.iso8601,
        3.days.from_now.beginning_of_hour.iso8601,
        7.days.from_now.beginning_of_hour.iso8601
      ]
    }
  end

  def meeting_stances_for(poll)
    generate_stance_for(poll, reason: "", stance_choices_attributes: [
      { poll_option_id: poll.poll_option_ids[0] },
      { poll_option_id: poll.poll_option_ids[2] }
    ])
    generate_stance_for(poll, reason: "Sorry, this week is crazy for me!", stance_choices_attributes: [
      { poll_option_id: poll.poll_option_ids[0] }
    ])
    generate_stance_for(poll, reason: "I'm free whenever", stance_choices_attributes: [
      { poll_option_id: poll.poll_option_ids[0] },
      { poll_option_id: poll.poll_option_ids[1] },
      { poll_option_id: poll.poll_option_ids[2] }
    ])
    generate_stance_for(poll, reason: "", stance_choices_attributes: [
      { poll_option_id: poll.poll_option_ids[0] },
      { poll_option_id: poll.poll_option_ids[1] },
      { poll_option_id: poll.poll_option_ids[2] }
    ])
    generate_stance_for(poll, reason: "", stance_choices_attributes: [
      { poll_option_id: poll.poll_option_ids[0] },
      { poll_option_id: poll.poll_option_ids[1] }
    ])
  end

  def generate_stance_for(poll, reason:, choice: nil, stance_choices_attributes: [])
    Stance.create!(
      poll:        poll,
      participant: generate_participant_for(poll),
      stance_choices_attributes: stance_choices_attributes,
      reason:      reason,
      choice:      choice
    )
  end

  def generate_participant_for(poll)
    poll.community_of_type(:email).visitors.create(
      name:  Faker::Name.name,
      email: Faker::Internet.email
    )
  end
end