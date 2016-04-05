# frozen_string_literal: true
require 'rails_helper'

RSpec.describe 'Extension: Acts as Experience Points Record' do
  #let(:reason) { "Reasonable" }
  class self::DummyClass < ActiveRecord::Base
    def self.columns
      []
    end
  end

  module self::DummyClass::ExperiencePointsDisplayConcern
    extend ActiveSupport::Concern

    def points_display_reason
      "Reason"
    end
  end

  class self::DummyClass
    acts_as_experience_points_record
  end

  let!(:concern) { self::DummyClass::ExperiencePointsDisplayConcern }

  subject { self.class::DummyClass.new }
  it { is_expected.not_to be_manually_awarded }
  it { is_expected.to respond_to(:points_awarded) }
  it { is_expected.to respond_to(:course_user) }
  it { is_expected.to respond_to(:acting_as) }
  it { expect(subject.acting_as).to respond_to(:specific) }
  it 'includes its ExperiencePointsDisplayConcern', focus: true do
    #is_expected.to be_a(self::DummyClass::ExperiencePointsDisplayConcern  )
    #expect(concern).to eql(concern)
    #expect(subject.class.ancestors).to include(subject.class.name + "::ExperiencePointsDisplayConcern")
    #expect(subject.points_display_reason).to equal("Reason")
    is_expected.to respond_to(:points_display_reason)
  end
end
