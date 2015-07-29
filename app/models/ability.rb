class Ability
  include CanCan::Ability

  def initialize(user)
    # Define abilities for the passed in user here. For example:
    #
    user ||= User.new # guest user (not logged in)
    #   if user.admin?
    #     can :manage, :all
    #   else
    #     can :read, :all
    #   end
    #
    # The first argument to `can` is the action you are giving the user
    # permission to do.
    # If you pass :manage it will apply to every action. Other common actions
    # here are :read, :create, :update and :destroy.
    #
    # The second argument is the resource the user can perform the action on.
    # If you pass :all it will apply to every resource. Otherwise pass a Ruby
    # class of the resource.
    #
    # The third argument is an optional hash of conditions to further filter the
    # objects.
    # For example, here the user can only update published articles.
    #
    #   can :update, Article, :published => true
    #
    # See the wiki for details:
    # https://github.com/bryanrite/cancancan/wiki/Defining-Abilities
    
    # Images
    ############
    can :manage, Image do |image|
#      image.user_id == user.id
      true
    end
    can :create, Image

    # ImageFiles
    ############
    can :manage, ImageFile do |image_file|
      image_file.user_id == user.id
    end
    can :create, ImageFile

    # Shipments
    ############
    can :manage, Shipment do |shipment|
#      image.user_id == user.id
      true
    end
    can :create, Shipment

    # ShipmentFiles
    ############
    can :manage, ShipmentFile do |shipment_file|
      shipment_file.user_id == user.id
    end
    can :create, ShipmentFile

    # UserSettings
    ############
    can :manage, UserSetting do |user_setting|
      user_setting.user_id == user.id
    end
    can :create, UserSetting

    # LookupDefs
    ############
    can :manage, LookupDef do |lookup_def|
#      lookup_def.user_id == user.id
    end
    can :create, LookupDef
    
  end
end
