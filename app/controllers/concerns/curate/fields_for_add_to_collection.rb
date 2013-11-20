module Curate::FieldsForAddToCollection
  extend ActiveSupport::Concern

  included do
    helper_method :available_profiles
    helper_method :current_users_profile_sections
  end

protected

  def collection_options
    @collection_options ||= current_users_collections
  end

  def current_users_collections
    current_user ? current_user.collections.to_a : []
  end

  def available_profiles
    return [] unless current_user
    return [] unless current_user.profile
    [current_user.profile]
  end

  def current_users_profile_sections
    return [] unless current_user
    return [] unless current_user.profile
    current_user.profile.members
  end

end
