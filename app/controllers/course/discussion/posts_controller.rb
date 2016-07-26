# frozen_string_literal: true
class Course::Discussion::PostsController < Course::ComponentController
  before_action :load_topic
  authorize_resource :specific_topic
# load  and auth posts --- done in concern . TO double check
# remove old conterollers + specs
# don't need to pass so many params in the js file

  include Course::Discussion::PostsConcern

  def create
    render status: :bad_request unless super
  end

  def update
    render status: :bad_request unless super
  end

  def destroy
    render status: :bad_request unless super
  end

  protected

  def discussion_topic
    @topic
  end

  def create_topic_subscription
    # TODO: Implement topic subscriptions
    true
  end

  private

  def topic_id_param
    params.permit(:topic_id)[:topic_id]
  end

  def load_topic
    @topic ||= Course::Discussion::Topic.find(topic_id_param)
    @specific_topic = @topic.specific
  end
end
