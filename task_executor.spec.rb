require 'rspec'
require_relative 'test_data'
require_relative 'errand_extractor'
require_relative 'task_executor'

describe TaskExecutor do
  describe "TaskExecutor.group_tasks" do
    it "groups tasks by time and partitions them" do
      tasks = ErrandExtractor.new(test_payload).run.errands
      task_executor = TaskExecutor.new(nil, tasks, 'bodunadebiyi')
      task_executor.group_tasks_by_time_and_partition
      expect(task_executor.grouped_and_partitioned).to eq({
        "2024-11-11" =>  [
          [{:command=>["<", "remove", "on", "2024-11-11", "", ""], :filename=>"app/models/employee.rb", :line=>"-0,0 +1,3"}],
          []
        ],
        "4 weeks" => [
          [],
          [{:command=>["<", "remind me", "in", "4 weeks", "to", "refactor this method"], :filename=>"app/controllers/application_controller.rb", :line=>"-46,4 +46,21"}]
        ],
        "2 weeks" => [
          [{:command=>["<", "cleanup", "in", "2 weeks", "", ""], :filename=>"app/controllers/application_controller.rb", :line=>"-46,4 +46,21"}],
          []
        ]
      })
    end
  end
end
