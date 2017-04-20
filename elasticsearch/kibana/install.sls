{% from "elasticsearch/kibana/map.jinja" import kibana with context %}

include:
  - elasticsearch.repository

install_kibana:
  pkg.installed:
    - pkgs: {{ kibana.pkgs }}
    - reload_modules: True
    - update: True
    - require:
      - pkgrepo: configure_elasticsearch_package_repo