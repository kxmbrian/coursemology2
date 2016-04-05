# frozen_string_literal: true
module Course::ExperiencePointsRecordsHelper
  # Formats the reason for the current experience points record for display.
  # Generates a link to the resource awarding the points if there is one.
  #
  # @param [Course::ExperiencePointsRecord] experience_points_record The record to be displayed.
  # @return [String] The formatted reason for the awarding of the points
  def display_reason(experience_points_record)
    if experience_points_record.reason.nil? && experience_points_record.specific.present?
      specific_item = experience_points_record.specific
      reason = format_inline_text(specific_item.points_display_reason)
      link = specific_item.points_display_link_path_array
      link.nil? ? reason : link_to(reason, link)
    else
      format_inline_text(experience_points_record.reason)
    end
  end
end
