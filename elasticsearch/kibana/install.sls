{% from "elasticsearch/kibana/map.jinja" import kibana with context %}
{% from "elasticsearch/map.jinja" import elasticsearch with context %}
{% set os_family = grains['os_family'] %}

include:
  {% if kibana.es_client_node %}
  - elasticsearch.configure
  {% endif %}
  - elasticsearch.repository

{% if elasticsearch.use_elastic_stack %}
install_kibana:
  pkg.installed:
    - pkgs: {{ kibana.pkgs }}
    - reload_modules: True
    - update: True
{% endif %}