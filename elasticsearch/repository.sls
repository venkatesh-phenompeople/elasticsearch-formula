{% from "elasticsearch/map.jinja" import elasticsearch with context %}
{% set os_family = grains['os_family'] %}

{% if os_family == 'RedHat' %}
install_elasticsearch_gpg_key:
  cmd.run:
    - name: rpm --import https://packages.elastic.co/GPG-KEY-elasticsearch
    - require_in:
        - pkgrepo: configure_elasticsearch_package_repo
{% endif %}

configure_elasticsearch_package_repo:
  pkgrepo.managed:
    - humanname: ElasticSearch
    {% if os_family == 'Debian' %}
    - name: deb {{ elasticsearch.pkg_repo_base}}/{{ elasticsearch.pkg_repo_version }}/{{ elasticsearch.pkg_repo_suffix}} stable main
    - key_url: https://packages.elastic.co/GPG-KEY-elasticsearch
    {% elif os_family == 'RedHat' %}
    - name: elasticsearch
    - baseurl: {{ elasticsearch.pkg_repo_base}}/{{ elasticsearch.pkg_repo_version }}/{{ elasticsearch.pkg_repo_suffix}}
    - gpgcheck: 1
    - enabled: 1
    - keyid: GPG-KEY-elasticsearch
    - keyserver: https://packages.elastic.co
    {% endif %}
    - require_in:
        - pkg: install_elasticsearch
