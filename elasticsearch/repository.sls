{% from "elasticsearch/map.jinja" import elasticsearch with context %}
{% set os_family = grains['os_family'] %}

{% if os_family == 'RedHat' %}
install_elasticsearch_gpg_key:
  cmd.run:
    - name: rpm --import https://packages.elastic.co/GPG-KEY-elasticsearch
    - require_in:
        - pkgrepo: configure_elasticsearch_package_repo
{% endif %}

{% for name, version in elasticsearch.products.items() %}
configure_{{ name }}_package_repo:
  pkgrepo.managed:
    - humanname: {{ name }}
    {% if os_family == 'Debian' %}
    - name: deb {{ elasticsearch.pkg_repo_base}}/{{ name }}/{{ version }}/{{ elasticsearch.pkg_repo_suffix}} stable main
    {% elif os_family == 'RedHat' %}
    - name: {{ name }}
    - baseurl: {{ elasticsearch.pkg_repo_base}}/{{ name }}/{{ version }}/{{ elasticsearch.pkg_repo_suffix}}
    - gpgcheck: 1
    - enabled: 1
    {% endif %}
    - keyurl: https://packages.elastic.co/GPG-KEY-elasticsearch
{% endfor %}
