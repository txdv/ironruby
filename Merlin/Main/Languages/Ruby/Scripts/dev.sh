#!/usr/bin/env bash

export CURRENT=`pwd`
export RUBY_SCRIPTS=$CURRENT  
DROP=${CURRENT:(-23)}
export MERLIN_ROOT=${CURRENT%$DROP}

# ruby needs to be on the path
export RUBY18_BIN=
export RUBY18_EXE=ruby
export RUBY19_EXE=ruby1.9
export RUBYOPT=
export GEM_PATH="$MERLIN_ROOT/../External.LCA_RESTRICTED/Languages/Ruby/ruby-1.8.6p287/lib/ruby/gems/1.8"

chmod +x $MERLIN_ROOT/../External.LCA_RESTRICTED/Languages/IronRuby/mspec/mspec/bin/{mspec,mspec-ci,mkspec,mspec-run,mspec-tag}    
chmod +x $MERLIN_ROOT/Test/Scripts/ir

export PATH="$MERLIN_ROOT/Languages/Ruby/Scripts:$MERLIN_ROOT/Languages/Ruby/Scripts/bin:$RUBY18_BIN:$MERLIN_ROOT/../External.LCA_RESTRICTED/Languages/IronRuby/mspec/mspec/bin:$PATH"
          
if [ ! -f ~/.mspecrc ]; then
  cp $MERLIN_ROOT/Languages/Ruby/default.mspec ~/.mspecrc
fi

#source Bat/aliases.bash
cd $CURRENT

# Run user specific setup
#if EXIST %MERLIN_ROOT%/../Users/%USERNAME%/Dev.bat call %MERLIN_ROOT%/../Users/%USERNAME%/Dev.bat

# clear               



