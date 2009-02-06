# ****************************************************************************
#
# Copyright (c) Microsoft Corporation. 
#
# This source code is subject to terms and conditions of the Microsoft Public License. A 
# copy of the license can be found in the License.html file at the root of this distribution. If 
# you cannot locate the  Microsoft Public License, please send an email to 
# ironruby@microsoft.com. By using this source code in any fashion, you are agreeing to be bound 
# by the terms of the Microsoft Public License.
#
# You must not remove this notice, or any other, from this software.
#
#
# ****************************************************************************

PACKAGE_DIR           = File.expand_path(File.dirname(__FILE__) + '/../../../../../dist/')  # directory that binary package is created in
MERLIN_ROOT           = File.expand_path(File.dirname(__FILE__) + '/../../..')
BUILD_BIN             = "#{MERLIN_ROOT}/bin/#{'mono_' if mono?}debug"

desc "Generate an IronRuby binary redist package from the layout"
task :package do
  # Directory layouts
  FileUtils.remove_dir(PACKAGE_DIR, true) if File.exist? PACKAGE_DIR
  FileUtils.mkdir_p "#{PACKAGE_DIR}/bin"
  
  # Copy Licenses
  FileUtils.cp Dir.glob("#{MERLIN_ROOT}/Languages/Ruby/Licenses/*"), PACKAGE_DIR

  # Copy binaries
  FileUtils.cp "#{MERLIN_ROOT}/app.config", "#{PACKAGE_DIR}/bin/ir.exe.config"
  FileUtils.cp "#{BUILD_BIN}/ir.exe", "#{PACKAGE_DIR}/bin/"
  FileUtils.cp Dir.glob("#{BUILD_BIN}/IronRuby*.dll"), "#{PACKAGE_DIR}/bin"
  FileUtils.cp "#{BUILD_BIN}/Microsoft.Scripting.Core.dll", "#{PACKAGE_DIR}/bin"
  FileUtils.cp "#{BUILD_BIN}/Microsoft.Scripting.dll", "#{PACKAGE_DIR}/bin"
  
  FileUtils.cp Dir.glob("#{MERLIN_ROOT}/Languages/Ruby/Scripts/bin/*"), "#{PACKAGE_DIR}/bin"

  # Generate ir.exe.config
  IronRubyCompiler.transform_config_file 'Binary', project_root + 'app.config.mono', "#{PACKAGE_DIR}/bin/ir.exe.config"

  # Copy standard library
  FileUtils.mkdir_p "#{PACKAGE_DIR}/lib/ruby" unless File.exist? "#{PACKAGE_DIR}/lib/ruby"
  FileUtils.cp_r "#{MERLIN_ROOT}/../External/Languages/Ruby/redist-libs/ruby", "#{PACKAGE_DIR}/lib/ruby"
  FileUtils.cp_r "#{MERLIN_ROOT}/Languages/Ruby/Libs", "#{PACKAGE_DIR}/lib/ironruby"

  # Generate compressed package
  if ENV['ZIP']
    system %Q{del "#{ENV['TEMP']}\\ironruby.7z"}
    system %Q{"#{ENV['PROGRAM_FILES_32']}/7-Zip/7z.exe" a -bd -t7z -mx9 "#{ENV['TEMP']}\\ironruby.7z" "#{PACKAGE_DIR}\\"}
    system %Q{"#{ENV['PROGRAM_FILES_32']}/7-Zip/7z.exe" a -bd -tzip -mx9 "c:\\ironruby.zip" "#{PACKAGE_DIR}\\"}
    system %Q{copy /b /Y "#{ENV['PROGRAM_FILES_32']}\\7-Zip\\7zSD.sfx" + "#{ENV['MERLIN_ROOT']}\\Languages\\Ruby\\sfx_config.txt" + "#{ENV['TEMP']}\\ironruby.7z" "c:\\ironruby.exe"}
  end
end
