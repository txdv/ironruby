function get-batchfile {
  param([string]$file)
  $cmd = "`"$file`" & set"
  cmd /c $cmd | Foreach-Object {
      $p, $v = $_.split('=')
      Set-Item -path env:$p -value $v
  }
}

function initialize-merlin {
  param([string]$path = "C:\vsl\")

  initialize-vsvars

  set TERM=
  set MERLIN_ROOT="$path\Merlin\Main"
  set MERLIN_EXTERNAL="${env:MERLIN_ROOT}\..\External.LCA_RESTRICTED"
  set RUBY18_BIN="${env:MERLIN_EXTERNAL}\Languages\Ruby\ruby-1.8.6p368\bin"
  set RUBY18_EXE="${env:RUBY18_BIN}\ruby.exe"
  set RUBY19_EXE="${env:MERLIN_EXTERNAL}\Languages\Ruby\1.9.1p0\bin\ruby.exe"
  set GEM_PATH="${env:MERLIN_EXTERNAL}\Languages\Ruby\ruby-1.8.6p368\lib\ruby\gems\1.8"
  $alias = $env:MERLIN_ROOT + '\Scripts\bat\Alias.ps1'
  $alias_internal = $env:MERLIN_ROOT + '\Scripts\bat\AliasInternal.ps1'
  if (test-path $alias) { . $alias }
  if (test-path $alias_internal) { . $alias_internal }
   
  if (Test-Path function:r) {Remove-item -Force function:r}
  . $scripts\append-path.ps1 "${env:RUBY18_BIN}"
  . $scripts\append-path.ps1 "${env:MERLIN_ROOT}\External\Tools"
  . $scripts\append-path.ps1 "${env:MERLIN_ROOT}\Scripts\Bat"
  . $scripts\append-path.ps1 "${env:MERLIN_ROOT}\..\Snap\bin"
  . $scripts\append-path.ps1 "${env:MERLIN_EXTERNAL}\Languages\IronRuby\mspec\mspec\bin"   
  . $scripts\append-path.ps1 "${env:MERLIN_ROOT}\Languages\Ruby\Scripts"
  . $scripts\append-path.ps1 "${env:MERLIN_ROOT}\Languages\Ruby\Scripts\Bin"

  function global:dbin { cd "${env:MERLIN_ROOT}\Bin\Debug" }
  function global:rbin { cd "${env:MERLIN_ROOT}\Bin\Release" }
  if (Test-Path function:\rbt) { Remove-Item -Force function:\rbt }
  function global:rbl { cd "${env:MERLIN_ROOT}\Languages\Ruby\IronRuby.Libraries"}
  function global:rbt { cd "${env:MERLIN_ROOT}\Languages\Ruby\Tests"}
  function global:script { cd "${env:MERLIN_ROOT}\Scripts\Bat" }
  function global:root { cd "${env:MERLIN_ROOT}" }
  function global:ext { cd "${env:MERLIN_EXTERNAL}"}
  function global:d {devenv $args}
  if (Test-Path function:ruby) {Remove-item -Force function:ruby}
  if (Test-Path function:irb) {Remove-item -Force function:irb}
  rb
}

function initialize-vsvars {
  param([string]$version = "9.0")

  if (test-path HKLM:SOFTWARE\Wow6432Node\Microsoft\VisualStudio\$version) {
          $VsKey = get-itemproperty HKLM:SOFTWARE\Wow6432Node\Microsoft\VisualStudio\$version
  }
  else {
          if (test-path HKLM:SOFTWARE\Microsoft\VisualStudio\$version) {
                  $VsKey = get-itemproperty HKLM:SOFTWARE\Microsoft\VisualStudio\$version
          }
  }
    $VsInstallPath = [System.IO.Path]::GetDirectoryName($VsKey.InstallDir)
    $VsToolsDir = [System.IO.Path]::GetDirectoryName($VsInstallPath)
    $VsToolsDir = [System.IO.Path]::Combine($VsToolsDir, "Tools")
    $BatchFile = [System.IO.Path]::Combine($VsToolsDir, "vsvars32.bat")
    Get-Batchfile $BatchFile
    "Visual Studio $version Configured"
  
}

function write-command {
  param(
        [string]$command,
        [string]$message
       )
  $logfile = $env:logfile    
  $command | out-file $logfile -Append
  Invoke-Expression $command | out-file $logfile -Append
  if ($LASTEXITCODE -ne 0) {
    write-error "Command $command failed!"    
    exit-pushd
    exit 1
  }
}

function exit-pushd {
  while((Get-Command -stack).count -gt 0) {
    Pop-Location  
  }  
}
Export-ModuleMember initialize-merlin, initialize-vsvars, write-command,
exit-pushd


