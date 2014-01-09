# Perf
Perf is a lightweight library for collecting and reporting performance data, which works for standalone applications and for distributed systems.
## Installation
Add this line to your application's Gemfile:

    gem 'perf'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install perf
## Usage
Perf is a simple mix-in module; include it into your class (with include/extend) - and you're ready to go.
```ruby
include Perf
```

This will not make your code run faster, but it will set up the environment for figuring out where your bottlenecks are. Now your class has a method called <i>collect</i> that lets you measuring performance of a code block.
###Collecting Data
Collecting performance data is very simple:

```ruby
def foo
  # Some code 
  collect counter do
    # code to measure
  end
  # Some code
end
```

Perf module provides the following counters out of the box:
* <i>hits</i>       increments values before executing the code block. 
* <i>totals</i>     increments values upon successful execution (i.e. no exceptions) of the code block.
* <i>activity</i>   increments values before the code block, and decrements afterwards.
* <i>failures</i>   increments values when the code block throws an exception.
* <i>duration</i>   records duration of the code block (in seconds) upon successful execution by incrementing specified value.
* <i>throughput</i> records duration and volume. 

A call to <i>collect</i> may include any number of counters:
```ruby
collect activity(:acive_uploads, active_upload_size: file.size), totals(:total_uploads, uploaded_size: file.size) do
  # Upload a file
end
```
The code block following <i>collect</i> is optional, and you can easily write something like that:
```ruby
# Some code
collect totals(:total_uploads, uploaded_size: file.size)
# More code
```
Note that without the code block <i>hits</i> and <i>totals</i> counters behave the same way, and <i>activity</i> counters do nothing. 

For <i>hits</i>, <i>totals</i>, and <i>activity</i> counters you may explicity specify value by which counter should be changed:
```ruby
collect totals(:uploaded_count, uploaded_size: file.size)
```
In this case value of <i>uploaded_count</i> counter will be incremented by one, but value of <i>uploaded_size</i> - by file.size.
#### Hits
Hits counters increment specified value(s) by one (by default) or by explicitly specified delta before executing the code block. They answer questions like:
* How many times have we tried to perform this operation?
* What's the overall volume of data have we tried to process?

The example below collects statistics on uploading operations:
```ruby
collect hits(:attempted_uploads, attempted_upload_size: file.size) do
  # upload a file
end
```
The code will increment <i>attempted_uploads</i> and <i>attempted_upload_size</i> counters before trying to upload. The actual result of uploading doesn't really matter.
#### Totals
Totals counter report data for successful operations only - when code block did not throw any exceptions. Like hits counter, they increment values by one by default, or by explicitly specified delta:
```ruby
collect totals(:successful_uploads, successful_upload_size: file.size) do
  # upload a file
end
```
#### Activity
Activity counters increment values before the code block and decrement them after. They are used to report 'active' data:
* How many tasks are being executed at this moment?
* How much data are we processing right now?

Once again, you can explicitly specify delta by which certain counters should be incremented/decremented:
```ruby
collect activity(:active_uploads, active_upload_size: file.size) do
  # upload a file
end
```
Unlike <i>hits</i> and <i>totals</i>, <i>activity</i> is a volatile counter. If a process executing the code block crashes, or if the mahcine looses connectivity, pending activity counters will eventually fix themselves. The time-to-live period is implementation-specific.
#### Failures
Failures counter reports errors. The values get incremented only if the code block throws an exception. 
```ruby
collect failures(:failed_upload_count) do
  # upload a file
end
```
#### Duration
Duration counter records duration of the code block (in seconds). Only successful execution counts - if the block throws, nothing gets reported.
```ruby
collect duration(:total_upload_time) do
  # upload a file
end
```
#### Throughput
Throughput counter reports duration and volume of a call. It is a combination of a duration and a totals counter.
```ruby
collect throughput(upload: file.size) do
  # Upload a file
end
```
The example below will increment two counters: <i>upload.duration</i> for the durarion of upload, and <i>upload.volume</i> for the file size.
### Retrieving data
Current values of all counters can be obtained by calling Perf::Data.get method, which returns a hash table with counters and their values:
```ruby
data = Perf::Data.get
# Do whatever you want 
```
### Resetting data
There may be situations in which you may want to reset all perf data and start from scratch:
```ruby
Perf::Data.reset
```
## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
