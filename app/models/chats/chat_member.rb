class ChatMember < ActiveRecord::Base
  belongs_to :user
  belongs_to :chat

  def initialize(attributes = {})
    super

    # Set default role for members
    self.roles = ['member']
  end

  ROLES = %w[member admin].freeze

  def roles=(roles)
    roles = roles.map { |r| r.to_s }
    self.roles_mask = (roles & ROLES).map { |r| 2**ROLES.index(r) }.inject(0, :+)
  end

  def roles
    ROLES.reject do |r|
      ((roles_mask.to_i || 0) & 2**ROLES.index(r)).zero?
    end
  end
end
