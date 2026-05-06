# Simple Task DSL for One-For-All
@tasks = {}
@last_desc = nil

def desc(text)
  @last_desc = text
end

def task(name, &block)
  @tasks[name.to_sym] = {
    desc: @last_desc,
    block: block
  }
  @last_desc = nil
end

def run_task(name)
  task_data = @tasks[name.to_sym]
  if task_data
    puts "=> Running task: #{name}"
    task_data[:block].call
    puts "=> Completed task: #{name}"
  else
    puts "❌ Error: Task '#{name}' not found."
    puts "Available tasks:"
    @tasks.each do |n, data|
      puts "  #{n.to_s.ljust(15)} # #{data[:desc]}"
    end
  end
end
