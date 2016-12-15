{% from "elasticsearch/map.jinja" import elasticsearch with context %}
{% set stack_version = salt.pillar.get('elasticsearch:stack_version', '5.x') %}
{% set os_family = grains['os_family'] %}

{% if os_family == 'RedHat' %}
install_elasticsearch_gpg_key:
  cmd.run:
    - name: rpm --import https://artifacts.elastic.co/GPG-KEY-elasticsearch
    - require_in:
        - pkgrepo: configure_elastic_stack_package_repo
{% endif %}

configure_elastic_stack_package_repo:
  pkgrepo.managed:
    - humanname: Elastic Stack Repository
    {% if os_family == 'Debian' %}
    - name: deb https://artifacts.elastic.co/{{ stack_version }}/apt stable main
    - refresh_db: True
    {% elif os_family == 'RedHat' %}
    - name: Elastic Stack Repository
    - baseurl: https://artifacts.elastic.co/{{ stack_version }}/yum
    - gpgcheck: 1
    - enabled: 1
    {% endif %}
    - key_url: https://artifacts.elastic.co/GPG-KEY-elasticsearch
