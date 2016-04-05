# frozen_string_literal: true
module Extensions::ActsAsHelpers::ActiveRecord::Base
  module ClassMethods
    # Decorator for items that give course_users EXP Points
    def acts_as_experience_points_record
      acts_as :experience_points_record, class_name: Course::ExperiencePointsRecord.name
      include ExperiencePointsInstanceMethods
      include "#{name}ExperiencePointsDisplayConcern".constantize
    end

    # Decorator for abstractions with concrete occurrences which have
    # the potential to award course_users EXP Points
    def acts_as_lesson_plan_item
      acts_as :lesson_plan_item, class_name: Course::LessonPlan::Item.name
    end
  end

  module ExperiencePointsInstanceMethods
    def manually_awarded?
      false
    end

    # The description to be displayed in the 'reason' column for the experience point record on
    # the experience poitns history page.
    # This method is to be overridden by each class that acts as an experience points record.
    #
    # @return [String] Reason which will be displayed
    def points_display_reason
      raise NotImplementedError
    end

    # Link for the experience points record's entry in the 'reason' column. The user should be
    # able to view the specific item awarding the points by clicking on the link.
    # This method is to be overridden by each class that acts as an experience points record.
    #
    # @return [Array] Path to item
    def points_display_link_path_array
      raise NotImplementedError
    end
  end
end
