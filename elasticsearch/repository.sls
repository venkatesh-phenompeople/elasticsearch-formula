{% from "elasticsearch/map.jinja" import elasticsearch with context %}
{% set os_family = grains['os_family'] %}

configure_elasticsearch_package_repo:
  pkgrepo.managed:
    - humanname: ElasticSearch
    {% if os_family == 'Debian' %}
    - name: deb {{ elasticsearch.pkg_repo_base}}/{{ elasticsearch.pkg_repo_version }}/{{ elasticsearch.pkg_repo_suffix}} stable main
    {% elif os_family == 'RedHat' %}
    - baseurl: {{ elasticsearch.pkg_repo_base}}/{{ elasticsearch.pkg_repo_version }}/{{ elasticsearch.pkg_repo_suffix}}
    - gpgcheck: 1
    - enabled: 1
    {% endif %}
    - key_url: http://packages.elastic.co/GPG-KEY-elasticsearch
    - require_in:
        - pkg: install_elasticsearch
