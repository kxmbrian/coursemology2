require 'rails_helper'

RSpec.describe Course::Assessment::ProgrammingTestCaseReport do
  self::REPORT_PATH = File.join(Rails.root, 'spec/fixtures/course/programming_test_case_report.xml')
  self::REPORT_XML = File.read(self::REPORT_PATH)

  let(:parsed_report) { Course::Assessment::ProgrammingTestCaseReport.new(self.class::REPORT_XML) }
  subject { parsed_report }

  describe '#test_suites' do
    it 'returns all the test suites in the report' do
      expect(subject.test_suites.length).to eq(2)
    end
  end

  describe '#test_cases' do
    it 'returns all the test cases in the report' do
      expect(subject.test_cases.length).to eq(3)
    end
  end

  describe Course::Assessment::ProgrammingTestCaseReport::TestSuite do
    subject { parsed_report.test_suites.second }

    describe '#name' do
      it 'returns the name attribute' do
        expect(subject.name).to eq('JUnitXmlReporter.constructor')
      end
    end

    describe '#identifier' do
      it 'generates an identifer for the test suite' do
        expect(subject.identifier).to eq(subject.name)
      end
    end

    describe '#duration' do
      it 'returns the time attribute' do
        expect(subject.duration).to eq(0.006)
      end
    end

    describe '#test_cases' do
      it 'returns all test cases in the suite' do
        expect(subject.test_cases.length).to eq(3)
      end
    end
  end

  describe Course::Assessment::ProgrammingTestCaseReport::TestCase do
    let(:test_cases) { parsed_report.test_suites.second.test_cases }
    subject { test_cases.first }

    describe '#class_name' do
      it 'returns the classname attribute' do
        expect(subject.class_name).to eq('JUnitXmlReporter.constructor')
      end
    end

    describe '#name' do
      it 'returns the name attribute' do
        expect(subject.name).to eq('should default path to an empty string')
      end
    end

    describe '#identifier' do
      it 'generates an identifer for the test suite' do
        expect(subject.identifier).to include(subject.test_suite.name)
        expect(subject.identifier).to include(subject.name)
      end
    end

    describe '#duration' do
      it 'returns the time attribute' do
        expect(subject.duration).to eq(0.006)
      end
    end

    context 'when the test case failed' do
      subject { test_cases.first }
      it { is_expected.to be_failed }
    end

    context 'when the test case was skipped' do
      subject { test_cases.second }
      it { is_expected.to be_skipped }
    end

    context 'when the test case passed' do
      subject { test_cases.third }
      it { is_expected.to be_passed }
    end
  end
end
