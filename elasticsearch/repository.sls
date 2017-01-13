{% from "elasticsearch/map.jinja" import elasticsearch with context %}
{% set os_family = grains['os_family'] %}

{% if os_family == 'RedHat' %}
install_elasticsearch_gpg_key:
  cmd.run:
    - name: rpm --import {{ elasticsearch.gpg-key }}
    - require_in:
        - pkgrepo: configure_elasticsearch_package_repo
{% endif %}

configure_elasticsearch_package_repo:
  pkgrepo.managed:
    - humanname: 'Elastic Stack'
    {% if os_family == 'Debian' %}
    - name: deb {{ elasticsearch.pkg_repo_url }}/apt stable main
    - refresh_db: True
    {% elif os_family == 'RedHat' %}
    - name: {{ name }}
    - baseurl: {{ elasticsearch.pkg_repo_url }}/yum
    - gpgcheck: 1
    - enabled: 1
    {% endif %}
    - key_url: {{ elasticsearch.gpg_key }}

configure_openjdk_repo:
    pkgrepo.managed:
    - humanname: 'OpenJDK'
    - name: {{ elasticsearch.openjdk_repo }}
    {% if os_family == 'Ubuntu' %}
    - key: {{ elasticsearch.openjdk_key }}
    - keyserver: {{ elasticsearch.keyserver}}
    {% endif %}
    - require_in:
        - install_pkg_dependencies
