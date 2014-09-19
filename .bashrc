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