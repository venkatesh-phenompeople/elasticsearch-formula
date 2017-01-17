{% from "elasticsearch/map.jinja" import elasticsearch with context %}

include:
    - .repository

install_pkg_dependencies:
  pkg.installed:
    - pkgs: {{ elasticsearch.pkgs }}
    - refresh: True
    - require:
        - pkgrepo: configure_openjdk_repo
    - require_in:
        - pkgrepo: configure_elasticsearch_package_repo

install_elasticsearch:
  pkg.installed:
    - name: elasticsearch
    - refresh: True
    - skip_verify: {{ not elasticsearch.get('verify_package', True) }}
    - require:
        - pkgrepo: configure_elasticsearch_package_repo
        - pkg: install_pkg_dependencies