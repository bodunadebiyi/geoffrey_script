require 'rspec'
require_relative 'file_cleaner'

commands = [{filename: "app/controllers/application_controller.rb", command: ["", "cleanup", "in", "2 weeks", "", ""], line: "-46,4 +46,21"},
{filename: "app/controllers/application_controller.rb", command: ["<", "remind me", "in", "4 weeks", "to", "refactor this method"], line: "-46,4 +46,21"},
{filename: "app/models/employee.rb", command: ["", "remove", "on", "2024-11-11", "", ""], line: "-0,0 +1,3"}]

file_cleaner = FileCleaner.new("test_file", "new_file", commands)

describe FileCleaner do
  describe "reset_state" do
    it "correctly resets the state" do
      file_cleaner.within_cleanup_block = true
      file_cleaner.search_for_closing_block = true
      file_cleaner.indentation_count = 2
      file_cleaner.reset_state

      expect(file_cleaner.within_cleanup_block).to eq(false)
      expect(file_cleaner.search_for_closing_block).to eq(false)
      expect(file_cleaner.indentation_count).to eq(nil)
    end
  end

  describe "get_identation_count" do
    it "correctly returns the indentation count" do
      line = "  def run"
      expect(FileCleaner.get_indentation_count(line)).to eq(2)
    end
  end

  describe "line_has_cleanup_command?" do
    it "correctly returns true if line has a cleanup command" do
      line = "some additional stuff @ geoffrey cleanup in 2 weeks"
      expect(file_cleaner.line_has_cleanup_command?(line)).to eq(true)
    end

    it "correctly returns false if line does not have a cleanup command" do
      line = "def run"
      expect(file_cleaner.line_has_cleanup_command?(line)).to eq(false)
    end

    it "correctly returns false if command is valid but doesn't belong to geoffrey" do
      line = "some additional stuff @ geoffrey cleanup in 5 weeks"
      expect(file_cleaner.line_has_cleanup_command?(line)).to eq(false)
    end
  end

  describe "is_line_cleanup?" do
    it "correctly returns true if line is an inline cleanup command" do
      line = "some additional stuff @ geoffrey cleanup in 2 weeks"
      expect(FileCleaner.is_inline_cleanup?(line)).to eq(true)
    end

    it "correctly returns false if line is not an inline cleanup command" do
      line = "  @ geoffrey cleanup in 2 weeks"
      expect(FileCleaner.is_inline_cleanup?(line)).to eq(false)
    end
  end

  describe "get_intent" do

  end
end
