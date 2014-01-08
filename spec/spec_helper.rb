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