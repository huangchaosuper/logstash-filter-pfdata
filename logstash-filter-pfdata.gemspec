Gem::Specification.new do |s|
  s.name = 'logstash-filter-pfdata'
  s.version         = '2.0.3'
  s.licenses = ['Apache License (2.0)']
  s.summary = "Filter for parse json base64 of pfdata"
  s.description = "Filter for parse json base64 of pfdata"
  s.authors = ["huangchaosuper"]
  s.email = 'huangchaosuper@live.cn'
  s.homepage = "https://github.com/huangchaosuper/logstash-filter-pfdata"
  s.require_paths = ["lib"]

  # Files
  s.files = Dir['lib/**/*','spec/**/*','vendor/**/*','*.gemspec','*.md','CONTRIBUTORS','Gemfile','LICENSE','NOTICE.TXT']
   # Tests
  s.test_files = s.files.grep(%r{^(test|spec|features)/})

  # Special flag to let us know this is actually a logstash plugin
  s.metadata = { "logstash_plugin" => "true", "logstash_group" => "filter" }

  # Gem dependencies
  s.add_runtime_dependency "logstash-core", ">= 2.0.0", "< 3.0.0"
  s.add_runtime_dependency 'logstash-filter-date'
  s.add_development_dependency 'logstash-devutils'
end
