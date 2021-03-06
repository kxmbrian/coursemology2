# Represents one pending programming question evaluation.
#
# This is different from a job in that jobs are assigned to an arbitrary worker. These
# programming question evaluations can only be run on a specific worker,
#  a) has permission to access the course
#  b) has the programming language runtime to evaluate this submission
#
# Like trackable jobs, elements in this table are ephemeral.
#
# @see Course::Assessment::ProgrammingEvaluationService
class Course::Assessment::ProgrammingEvaluation < ActiveRecord::Base
  include Workflow

  # The time to elapse before an allocated job is deemed as dead and can be allocated to another
  # evaluator.
  TIMEOUT = 5.minutes

  workflow_column :status
  workflow do
    state :submitted do
      event :assign, transitions_to: :assigned
    end
    state :assigned do
      event :assign, transitions_to: :assigned
      event :complete, transitions_to: :completed
      event :error, transitions_to: :errored
    end
    state :completed
    state :errored
  end
  has_one_attachment

  after_commit :signal, if: :finished?

  validates :evaluator, :assigned_at, presence: true, unless: :submitted?
  validates :stdout, :stderr, :test_report, exclusion: [nil], if: :finished?

  belongs_to :course, inverse_of: :assessment_programming_evaluations
  belongs_to :language, class_name: Polyglot::Language.name, inverse_of: nil
  belongs_to :evaluator, class_name: User.name, inverse_of: nil

  # @!method self.with_language(languages)
  #   Gets the programming evaluation jobs with any of the given languages.
  scope :with_language, (lambda do |languages|
    joins(:language).merge(Polyglot::Language.with_language(languages))
  end)

  # @!method self.pending
  #   Gets the programming evaluation jobs which are in the submitted state, and pending
  #   allocation to an evaluator.
  scope :pending, (lambda do
    where do
      (status == 'submitted') | (
        (status == 'assigned') & (assigned_at < Time.zone.now - TIMEOUT))
    end
  end)

  # @!method self.finished
  #   Gets the programming evaluation jobs which have finished, which are those which are
  #   completed or errored.
  scope :finished, -> { where { (status == 'completed') | (status == 'errored') } }

  # Checks if the given task is finished
  #
  # @return [Boolean]
  def finished?
    completed? || errored?
  end

  protected

  # Handles the assign event.
  #
  # @param [User] assigned_evaluator The user  assigned to evaluate this evaluation.
  def assign(assigned_evaluator)
    self.evaluator = assigned_evaluator
    self.assigned_at = Time.zone.now
  end
end
