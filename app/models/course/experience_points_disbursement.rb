# frozen_string_literal: true
class Course::ExperiencePointsDisbursement
  include ActiveModel::Model
  include ActiveModel::Validations

  # @!attribute [rw] reason
  #   This reason for the disbursement.
  #   This will become the reason for each experience points record awarded.
  #   @return [String]
  attr_accessor :reason

  # @!attribute [r] course
  #   The course that this disbursement is for.
  #   This attibute reader is used during form-building.
  #   The attibute writer +course=+ is defined separately below.
  #   @return [Course]
  attr_reader :course

  # @!attribute [r] approved_students
  #   Approved students of the course that this disbursement is for.
  #   This attibute reader is used during form-building.
  #   @return [Array<CourseUser>]
  attr_reader :approved_students

  # @!attribute [r] experience_points_records
  #   Experience points records that will potentially be created.
  #   The controller uses this attibute reader to retrieve the points records for authorization.
  #   @return [Array<Course::ExperiencePointsRecords>]
  attr_reader :experience_points_records

  # @!attribute [r] records_hash
  #   Hash that map the id of a student to his newly built points record.
  #   This attibute reader is used during form-building.
  #   @return [Hash<Integer, Course::ExperiencePointsRecords>]
  attr_reader :records_hash

  # @!attribute [r] recipient_count
  #   The number of recipients who have been successfully awarded points.
  #   @return [Integer]
  attr_reader :recipient_count

  validates :reason, presence: true

  # Given a course, builds an empty experience points record for each of its
  # approved students.
  #
  # @param [Course] course The course the disbursement is for
  # @return [Course] The course the disbursement is for
  def course=(course)
    @course = course
    @approved_students = @course.course_users.students.with_approved_state
    @records_hash = @approved_students.map do |student|
      [student.id, student.experience_points_records.build]
    end.to_h
    @experience_points_records = @records_hash.values
    course
  end

  # Processes the course attributes hash, instantiating new points records for each course user
  # attributes hash that represents a valid award.
  #
  # @param [Hash] attributes Course attributes hash
  # @return [Hash] Course attributes hash
  def course_attributes=(attributes)
    course_users_attributes = valid_course_users_attributes(attributes)
    @recipient_count = course_users_attributes.length
    course_id = attributes[:id]
    @course = course_id.present? ? Course.find(course_id) : nil
    @course.course_users_attributes = course_users_attributes if @course.present?
    @experience_points_records =
      @course.course_users.includes(:experience_points_records, :user, :creator, :updater).map do |course_user|
        course_user.experience_points_records.select { |record| record.new_record? }
      end.flatten
    attributes
  end

  # Saves newly built experience points record
  #
  # @return [Boolean] True if bulk saving was successful.
  def save
    @course.present? ? @course.save : false
  end

  private

  # Extracts course users attribute hash from course attributes hash, filters out invalid
  # course user attribute hashes and injects the disbursement reason into each points record hash.
  #
  # @param [Hash] course_attributes Course attributes
  # @return [Hash] Hash containing course user attributes hashes that represent valid points awards
  def valid_course_users_attributes(course_attributes)
    course_users_attributes = course_attributes[:course_users_attributes]
    valid_awards = Hash.new
    course_users_attributes && course_users_attributes.each do |key, course_user_attributes|
      if is_valid_award(course_user_attributes)
        course_user_attributes[:experience_points_records_attributes].values.each do |record_attributes|
          record_attributes[:reason] = @reason
        end
        valid_awards[key] = course_user_attributes
      end
    end
    valid_awards
  end

  # Checks if a course user attributes hash represents a valid experience points award.
  #
  # @param [Hash] course_user_attributes Course user attributes hash
  # @return [Boolean] True if course user attributes hash represents a valid award.
  def is_valid_award(course_user_attributes)
    course_user_attributes[:id].present? &&
    course_user_attributes[:experience_points_records_attributes].present? &&
    course_user_attributes[:experience_points_records_attributes].values.map do |record_hash|
      record_hash[:points_awarded].present? &&
      record_hash[:points_awarded] != '0'
    end.all?
  end
end
