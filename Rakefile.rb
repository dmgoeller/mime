require "rake"
require "rake/testtask"
require "rdoc/task"

Rake::TestTask.new do |t|
  t.libs << "test"
  t.test_files = FileList['test/tc_*.rb']
  t.verbose = true
end

RDoc::Task.new do |t|
  t.rdoc_files.include("lib/*.rb", "lib/mime/*.rb")
  t.rdoc_dir = "doc/rdoc"
  t.markup = "markdown"
end

task :gem => [:test, :rdoc] do
  system "gem build mime.gemspec"
end

task :default => :gem
