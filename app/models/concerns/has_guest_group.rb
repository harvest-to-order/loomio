module HasGuestGroup
  extend ActiveSupport::Concern
  included do
    belongs_to :guest_group, class_name: "GuestGroup"
    has_many :guests, through: :guest_group, source: :members
  end

  def invite_guest!(name: nil, email:, inviter: nil)
    self.guest_group.invitations.find_or_create_by(
      recipient_email: email,
      intent: :join_group
    ).update(
      recipient_name: name,
      inviter: inviter
    )
  end

  def anyone_can_participate
    # TODO not sure what invitation -> voter flow is.
    guest_group.membership_granted_upon_request?
  end

  def anyone_can_participate=(bool)
    guest_group.update(membership_granted_upon: if bool then :request else :invitation end)
  end

end
