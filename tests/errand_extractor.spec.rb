require 'rspec'
require_relative '../test_data'
require_relative '../src/errand_extractor'

describe ErrandExtractor do
  describe "ErrandExtractor.capture" do
    it "capture works as expected" do
      test_text = "@@ -1,6 +1,6 @@"
      expect(ErrandExtractor.capture(test_text, "@@", "@@")).to eq(["-1,6 +1,6"])
    end
  end

  describe "ErrandExtractor.parse_command" do
    it "parses a valid command" do
      cmd_one = "@ geoffrey remove on 2024-11-11"
      cmd_two = "   <@geoffrey remind me in 4 weeks to refactor this method"

      parsed_command = ErrandExtractor.parse_command(cmd_one)
      parsed_command_two = ErrandExtractor.parse_command(cmd_two)

      expect(parsed_command).to eq(["", "remove", "on", "2024-11-11", "", ""])
      expect(parsed_command_two).to eq(["<", "remind me", "in", "4 weeks", "to", "refactor this method"])
    end

    it "throws an error with invalid command" do
      invalid_command = "<@geoffrey invalid command"
      expect {ErrandExtractor.parse_command(invalid_command)}.to raise_error(StandardError)
    end
  end

  describe "decision_engine" do
    it "adds errands to the list" do
      errand_extractor = ErrandExtractor.new(test_payload)
      errand_extractor.run
      expectation = [{
        :command => ["<", "cleanup", "in", "2 weeks", "", ""],
        :filename => "app/controllers/application_controller.rb",
        line: "-46,4 +46,21"
      }, {
        :command => ["<", "remind me", "in", "4 weeks", "to", "refactor this method"],
        :filename => "app/controllers/application_controller.rb",
        line: "-46,4 +46,21"
      }, {
        :command => ["<", "remove", "on", "2024-11-11", "", ""],
        :filename => "app/models/employee.rb",
        line: "-0,0 +1,3"
      }]
      expect(errand_extractor.errands).to eq(expectation)
    end
  end

  describe "ErrandExtractor.has_command?" do
    it "returns true if the line contains a command" do
      test_line = "some addition al stuff @ geoffrey cleanup in 2 weeks"
      expect(ErrandExtractor.has_command?(test_line)).to eq(true)
    end

    it "returns false if the line does not contain a command" do
      test_line = "def run"
      expect(ErrandExtractor.has_command?(test_line)).to eq(false)
    end
  end
end
