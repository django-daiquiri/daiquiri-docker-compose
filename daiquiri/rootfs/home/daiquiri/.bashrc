source /opt/source.sh
source /opt/ve.sh

alias ll='ls -alF --color=auto'
alias pm='python manage.py'

export DQIP=$(get_container_ip)
export LC_ALL=en_US.utf8