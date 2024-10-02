require 'rspec'
require_relative '../src/file_cleaner'

def commands
  [{filename: "app/controllers/application_controller.rb", command: ["", "cleanup", "in", "2 weeks", "", ""], line: "-46,4 +46,21"},
  {filename: "app/controllers/application_controller.rb", command: ["<", "delete", "in", "4 weeks", "to", "refactor this method"], line: "-46,4 +46,21"},
  {filename: "app/models/employee.rb", command: ["", "remove", "on", "2024-11-11", "", ""], line: "-0,0 +1,3"}]
end

def file_cleaner
  FileCleaner.new("test_file", "new_file", commands)
end

describe FileCleaner do
  describe "reset_state" do
    it "correctly resets the state" do
      fc = file_cleaner
      fc.within_cleanup_block = true
      fc.search_for_closing_block = true
      fc.indentation_count = 2
      fc.reset_state

      expect(fc.within_cleanup_block).to eq(false)
      expect(fc.search_for_closing_block).to eq(false)
      expect(fc.indentation_count).to eq(nil)
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
      line = "@ geoffrey cleanup in 2 weeks"
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

  describe "remove command from list" do
    it "correctly removes command from the list of commands" do
      command = ["", "cleanup", "in", "2 weeks", "", ""]
      fc = file_cleaner
      fc.remove_command_from_list(command)
      expect(fc.commands).to eq([commands[1], commands[2]])
    end
  end

  describe "get_intent" do
    it "returns :do_nothing if line has no command" do
      line = "def run"
      expect(file_cleaner.get_intent(line)).to eq(:do_nothing)
    end

    it "returns :delete_file if line has a command and is the first line" do
      line = "@ geoffrey cleanup in 2 weeks"
      expect(file_cleaner.get_intent(line)).to eq(:delete_file)
    end

    it "return :skip_line if line has a command and is not within a cleanup block and not inline command" do
      line = "@ geoffrey cleanup in 2 weeks"
      fc = file_cleaner
      fc.line_number = 5
      expect(fc.get_intent(line)).to eq(:skip_line)
      expect(fc.within_cleanup_block).to eq(true)
      expect(fc.search_for_closing_block).to eq(false)
    end

    it "returns skip line and sets state if line has a command block that requires a closing block" do
      line = "<@ geoffrey delete in 4 weeks to refactor this method"
      fc = file_cleaner
      fc.line_number = 5
      expect(fc.get_intent(line)).to eq(:skip_line)
      expect(fc.within_cleanup_block).to eq(true)
      expect(fc.search_for_closing_block).to eq(true)
    end

    it "return :skip line if within clean up block and found closing block" do
      line = "@ geoffrey >"
      fc = file_cleaner
      fc.within_cleanup_block = true
      fc.search_for_closing_block = true
      fc.line_number = 5

      expect(fc.get_intent(line)).to eq(:skip_line)
      expect(fc.within_cleanup_block).to eq(false)
      expect(fc.search_for_closing_block).to eq(false)
    end

    it "returns :skip_line if line is within a cleanup block and search_for_closing_block is true" do
      line = "def run"
      fc = file_cleaner
      fc.within_cleanup_block = true
      fc.search_for_closing_block = true
      expect(fc.get_intent(line)).to eq(:skip_line)
    end
  end
end
