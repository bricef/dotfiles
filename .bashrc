# .bashrc

#!/bin/bash
source ~/.common_bashrc
if [ "$(uname)" == "Darwin" ]; then
    source ~/.mac_bashrc       
elif [ "$(expr substr $(uname -s) 1 5)" == "Linux" ]; then
    source ~/.linux_bashrc
elif [ "$(expr substr $(uname -s) 1 10)" == "MINGW32_NT" ]; then
    source ~/.linux_bashrc
fi

export PATH="$PATH:$HOME/.rvm/bin" # Add RVM to PATH for scripting

# tabtab source for serverless package
# uninstall by removing these lines or running `tabtab uninstall serverless`
[ -f /usr/local/lib/node_modules/serverless/node_modules/tabtab/.completions/serverless.bash ] && . /usr/local/lib/node_modules/serverless/node_modules/tabtab/.completions/serverless.bash

# tabtab source for sls package
# uninstall by removing these lines or running `tabtab uninstall sls`
[ -f /usr/local/lib/node_modules/serverless/node_modules/tabtab/.completions/sls.bash ] && . /usr/local/lib/node_modules/serverless/node_modules/tabtab/.completions/sls.bash
