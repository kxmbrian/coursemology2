# frozen_string_literal: true
class Course::ExperiencePointsDisbursementController < Course::ComponentController
  include Course::UsersBreadcrumbConcern
  load_resource :experience_points_disbursement, class: Course::ExperiencePointsDisbursement.name

  def new # :nodoc:
    @experience_points_disbursement.course = current_course
    authorize_resource
  end

  def create # :nodoc:
    authorize_resource
    if @experience_points_disbursement.save
      redirect_to disburse_points_course_users_path(current_course),
                  success: t('.success', count: @experience_points_disbursement.recipient_count)
    else
      render 'new'
    end
  end

  private

  def experience_points_disbursement_params # :nodoc:
    params.require(:experience_points_disbursement).
           permit(:reason,
                  course_attributes:
                    [:id, course_users_attributes:
                            [:id, experience_points_records_attributes: :points_awarded]])
  end

  # Authorizes each experience points record built by the model
  def authorize_resource
    @experience_points_disbursement.experience_points_records.each do |record|
      authorize!(:create, record)
    end
  end
end
