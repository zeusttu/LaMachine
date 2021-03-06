#!/bin/bash

# THIS FILE IS MANAGED BY LAMACHINE, DO NOT EDIT IT! (it will be overwritten on update)

bold=$(tput bold)
boldred=${bold}$(tput setaf 1) #  red
boldgreen=${bold}$(tput setaf 2) #  green
boldblue=${bold}$(tput setaf 4) #  blue
normal=$(tput sgr0)

if [ -e "{{lm_path}}" ]; then
  cd "{{lm_path}}"
else
  echo "The LaMachine control directory was not found.">&2
  echo "this generally means this lamachine installation is externally managed.">&2
  exit 2
fi
if ! touch .lastupdate; then
  echo "Insufficient permission to update">&2
  exit 2
fi
if [ -d .git ]; then
    git pull
fi
FIRST=1
INTERACTIVE=1
if [ "$1" = "--edit" ]; then
    if [ -z "$EDITOR" ]; then
      export EDITOR=nano
    fi
    if [ -e "host_vars/{{hostname}}.yml" ]; then
        #LaMachine v2.1.0+
        $EDITOR "host_vars/{{hostname}}.yml"
    elif [ -e "host_vars/localhost.yml" ]; then
        #fallback
        $EDITOR "host_vars/localhost.yml"
    elif [ -e "host_vars/lamachine-$LM_NAME.yml" ]; then
        #LaMachine v2.0.0
        $EDITOR "host_vars/lamachine-$LM_NAME.yml"
    fi
    if [ -e "hosts.{{conf_name}}" ]; then
        #LaMachine v2.0.0
        $EDITOR "install-{{conf_name}}.yml"
    else
        #LaMachine v2.1.0+
        $EDITOR "install.yml"
    fi
    FIRST=2
elif [ "$1" = "--noninteractive" ]; then
    INTERACTIVE=0
fi
OPTS=""
if [[ {{root|int}} -eq 1 ]] && [[ $INTERACTIVE -eq 1 ]]; then
 OPTS="--ask-become-pass"
fi
D=$(date +%Y%m%d_%H%M%S)
if [ -e "hosts.{{conf_name}}" ]; then
    #LaMachine v2.0.0
    ansible-playbook -i "hosts.{{conf_name}}" "install-{{conf_name}}.yml" -v $OPTS --extra-vars "${*:$FIRST}" 2>&1 | tee "lamachine-{{conf_name}}-$D.log"
    rc=${PIPESTATUS[0]}
else
    #LaMachine v2.1.0+
    ansible-playbook -i "hosts.ini" "install.yml" -v $OPTS --extra-vars "${*:$FIRST}" 2>&1 | tee "lamachine-{{conf_name}}-$D.log"
    rc=${PIPESTATUS[0]}
fi
echo "======================================================================================"
if [ $rc -eq 0 ]; then
        echo "${boldgreen}The LaMachine update completed succesfully!${normal}"
        echo " - Log file: $(pwd)/lamachine-{{conf_name}}-$D.log"
else
        echo "${boldred}The LaMachine update failed!${normal} You have several options:"
        echo " - Retry a forced update (lamachine-update force=1), this forces recompilation even if software seems up to date"
        echo "   and may be necessary in certain circumstances."
        echo " - Retry the update, possibly tweaking configuration and installation options (lamachine-update --edit)"
        echo " - File a bug report on https://github.com/proycon/LaMachine/issues/"
        echo "   The log file has been written to $(pwd)/lamachine-{{conf_name}}-$D.log (include it with any bug report)"
fi
exit $rc
