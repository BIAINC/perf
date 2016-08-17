require 'simplecov'
SimpleCov.start

require 'perf'

def stub_storage(*methods)
  s = double('storage')
  methods.each{|m| allow(s).to receive(m)}
  allow(Perf::Configuration).to receive(:storage).and_return(s)
  s
end

RSpec::Matchers.define :be_a_counter do
  match do |actual|
    methods = actual.instance_methods
    methods.include?(:start) && methods.include?(:stop) && methods.include?(:error)
  end
end
