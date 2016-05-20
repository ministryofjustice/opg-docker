{%  if data['tag'] == 'salt/custom/start_highstate' %}
start_highstate:
  local.state.highstate:
    - tgt: '*'
{%  elif data['tag'] == 'salt/custom/active_jobs' %}
active_jobs:
  local.jobs.active:
    - tgt: '*'
{%  endif %}

