{% from "elasticsearch/map.jinja" import elasticsearch with context %}
{% set osfullname = salt.grains.get('osfullname') %}

include:
    - .repository

install_pkg_dependencies:
  pkg.installed:
    - pkgs: {{ elasticsearch.pkgs }}
    - refresh: True
    {% if osfullname == 'Debian' %}
    - require:
        - pkgrepo: configure_openjdk_repo
    {% endif %}
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