beacons:
  service:
    interval: 60
    services:
      - sshd:
          onchangeonly: True
      - firewalld:
          onchangeonly: True
      
  inotify:
    files:
      - /etc/ssh:
          mask:
            - create
            - modify
            - delete
          recurse: True

      - /etc/firewalld:
          mask:
            - create
            - modify
            - delete
          recurse: True

      - /etc/salt/minion.d:
          mask:
            - create
            - modify
            - delete
          recurse: True
      



FIRST WAY TO DO THIS REACTOR
---------------------------------------------------------------

location 
/etc/salt/master

reactor:
  - '/salt/beacon/*/service/':
    - srv/reactor/service_change_react.sls

+++++++++++++++++++++++++++++++++++++++++++++++++++++++

location
/srv/reactor

#service_change_react.sls

{%if data.get('service')== 'sshd' and not data.get('running') %}
  sshd_change_react:
    local.state.apply:
      - tgt: {{data['id']}}
      - arg:
        - sshd_service_start
{% elif data.get('service') == 'firewalld' and data.get('running') %}
  firewalld_change_react:
    local.state.apply:
      - tgt: {{data['id']}}
      - arg:
        - firewall_service_stop
{% endif %}

++++++++++++++++++++++++++++++++++++++++++++++++++++++

locatin
/srv/salt

#ssh_service_react

ssh_service_react:
  cmd.run:
    - name: 'systemctl enable --now sshd'
    - cwd: /home
    - runas: root
    - shell: /bin/bash
    

file2 
#firewall_service_stop.sls


firewall_service_stop:
  cmd.run:
    - name: 'systemctl stop firewalld'
    - cwd: /home
    - runas: root
    - shell: /bin/bash

+++++++++++++++++++++++++++++++++++++++++++++++++++++++



SECOND WAY TO DO THIS REACTOR

----------------------------------------------------------------

location 
/etc/salt/master

reactor:
  - '/salt/beacon/*/service/sshd':
    -  /srv/reactor/sshd_stopped.sls

  - '/salt/beacon/*/service/firewalld':
    -  /srv/reactor/firewalld_started.sls

+++++++++++++++++++++++++++++++++++++++++++++++++++++

location
/srv/reactor

#sshd_stopped.sls

sshd_stopped:
  local.state.apply:
    - tgt: {{data['id']}}
    - arg:
      - ssh_start


#firewalld_started

firewalld_started:
  local.state.apply:
    - tgt: {{data['id']}}
    - arg:
      - firewall_stop

++++++++++++++++++++++++++++++++++++++++++++++++++++

location
/srv/salt

#ssh_start.sls

ssh_start:
  cmd.run:
    - name: 'systemctl start sshd'
    - cwd: /home
    - runas: root
    - shell: /bin/bash


#firewall_stop.sls

firewall_stop:
  cmd.run:
    - name: 'systemctl stop firewalld'
    - cwd: /home
    - runas: root
    - shell: /bin/bash

--------------------------------------------------------


  
