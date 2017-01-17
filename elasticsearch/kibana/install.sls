{% from "elasticsearch/kibana/map.jinja" import kibana with context %}
{% from "elasticsearch/map.jinja" import elasticsearch with context %}

{% if elasticsearch.use_elastic_stack %}
install_kibana:
  pkg.installed:
    - pkgs: {{ kibana.pkgs }}
    - reload_modules: True
    - update: True
{% endif %}