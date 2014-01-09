require 'simplecov'
SimpleCov.start

require 'perf'
require 'perf/configuration'

def stub_storage(*methods)
  s = double('storage')
  methods.each{|m| s.stub(m)}
  Perf::Configuration.stub(:storage).and_return(s)
  s
end

RSpec::Matchers.define :be_a_counter do
  match do |actual|
    methods = actual.instance_methods
    methods.include?(:start) && methods.include?(:stop) && methods.include?(:error)
  end
end
