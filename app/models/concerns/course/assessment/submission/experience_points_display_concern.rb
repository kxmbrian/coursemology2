# frozen_string_literal: true
module Course::Assessment::Submission::ExperiencePointsDisplayConcern
  extend ActiveSupport::Concern

  # The reason to be displayed for the submission's experience point award.
  #
  # @return [String] Reason which will be displayed
  def points_display_reason
    assessment.title
  end

  # The array representing the path to the submission. The user will be directed to this path when
  # he clicks on the experience points reason.
  #
  # @return [Array] Path where the user can inspect the submission
  def points_display_link_path_array
    [:edit, assessment.course, assessment, self]
  end
end
