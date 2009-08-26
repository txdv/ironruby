#replace the Assert popup window with a message
engine = RUBY_ENGINE rescue 'notironruby'
if (ENV["THISISSNAP"] || ENV["SILENTASSERT"]) && engine == 'ironruby'
  class MyTraceListener < System::Diagnostics::DefaultTraceListener
    def fail(msg, detailMsg=nil)
      puts "ASSERT FAILED: #{msg}"
      puts "               #{detailMsg}" if detailMsg
    end
  end
  System::Diagnostics::Debug.Listeners.clear
  System::Diagnostics::Debug.Listeners.add(MyTraceListener.new)
end       

def mono?
  return true if ENV['mono']
  ENV['OS'] != "Windows_NT"
end 

def ir_cmd
  if mono?       
    "mono #{ENV['MERLIN_ROOT']}/Bin/mono_debug/ir.exe -X:Interpret "
  else    
    "#{ENV['MERLIN_ROOT']}/Test/Scripts/ir.cmd" unless mono?
  end
end
if engine == 'ironruby'
  $" << "resolv.rb"
end
class MSpecScript
  # The default implementation to run the specs.
  set :target, ir_cmd
  # config[:prefix] must be set before filtered is used
  set :prefix, "#{ENV['MERLIN_ROOT']}/../External.LCA_RESTRICTED/Languages/IronRuby/mspec/rubyspec"
  
  set :core1sub1,filtered("core","[ac-i]")
  set :core1sub2,[ #want to keep basicobject out of the 1.8 list
    "core/bignum",
    "core/binding",
    "core/builtin_constants"
  ]
  set :core2, filtered("core", "[j-z]").reject{|el| el =~ /thread/i}
  set :lang, [
    "language"
    ]
  set :cli, [
    "command_line"
    ]
  set :lib1, filtered("library", "[a-o]").reject {|el| el =~ /basicobject/ }
  set :lib2, filtered("library", "[p-z]")
  #.NET interop
  set :netinterop, [
    "../../../../../Main/Languages/Ruby/Tests/Interop/net"
    ]
  
  set :netcli, [
    "../../../../../Main/Languages/Ruby/Tests/Interop/cli"
    ]

  set :cominterop, [
    "../../../../../Main/Languages/Ruby/Tests/Interop/com"
    ]
  
  set :thread, [
    "core/thread",
    "core/threadgroup"
    ]

  #combination tasks
  set :core1, get(:core1sub1) + get(:core1sub2)
  set :core, get(:core1) + get(:core2)
  set :lib, get(:lib1) + get(:lib2)
  set :interop, get(:netinterop) + get(:cominterop)
  set :ci_files, get(:core) + get(:lang) + get(:cli) + get(:lib) + get(:interop)


  # The set of substitutions to transform a spec filename
  # into a tag filename.
  set :tags_patterns, [
                        [%r(rubyspec/), 'ironruby-tags/'],
                        [/interop\//i, 'interop/tags/'],
                        [/_spec.rb$/, '_tags.txt']
                      ]
end

