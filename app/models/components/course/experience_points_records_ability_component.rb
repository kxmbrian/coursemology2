module Course::ExperiencePointsRecordsAbilityComponent
  include AbilityHost::Component

  def define_permissions
    allow_users_managing_exp if user

    super
  end

  private

  def allow_users_managing_exp
    can :manage, Course::ExperiencePointsRecord
  end
end
