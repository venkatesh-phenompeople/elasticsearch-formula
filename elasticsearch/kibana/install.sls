{% from "elasticsearch/kibana/map.jinja" import kibana with context %}

install_kibana:
  pkg.installed:
    - pkgs: {{ kibana.pkgs }}
    - reload_modules: True
    - update: True