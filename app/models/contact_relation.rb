class ContactRelation < ActiveRecord::Base
  belongs_to :user
  belongs_to :contact, class_name: 'User'

  validates_uniqueness_of :contact_id, :scope => [:user_id]
  validates :contact_id, presence: true
  validates :user_id, presence: true
  validate :different_user_and_contact?, on: :create

  def to_api_response
    contact_info = super
    contact_info[:contact] = contact.to_api_response

    contact_info
  end

  private
  def different_user_and_contact?
    if user_id and user_id == contact_id
      errors.add :contact_id, 'and owner must be different!'
    end
  end
end