class Ability
  include Hydra::Ability
  
  include CurationConcerns::Ability
  include Sufia::Ability

  self.ability_logic += [:everyone_can_create_curation_concerns]
  self.ability_logic += [:umrdr_abilities]

  def umrdr_abilities
    alias_action :identifiers, to: :update
    alias_action :download, to: :create
  end

  # Define any customized permissions here.
  def custom_permissions
    # Limits deleting objects to a the admin user
    #
    # if current_user.admin?
    #   can [:destroy], ActiveFedora::Base
    # end

    # Limits creating new objects to a specific group
    #
    # if user_groups.include? 'special_group'
    #   can [:create], ActiveFedora::Base
    # end
  end
end
