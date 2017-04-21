{% from "elasticsearch/map.jinja" import elasticsearch, elasticsearch_repo with context %}
{% set os_family = salt.grains.get('os_family') %}
{% set osfullname = salt.grains.get('osfullname') %}

{% if os_family == 'RedHat' %}
install_elasticsearch_gpg_key:
  cmd.run:
    - name: rpm --import {{ elasticsearch.gpg-key }}
    - require_in:
        - pkgrepo: configure_elasticsearch_package_repo
{% endif %}

{% if elasticsearch.elastic_stack %}
configure_elasticsearch_package_repo:
  pkgrepo.managed:
    - humanname: Elasticsearch_{{ elasticsearch.version }}
    {% if os_family == 'Debian' %}
    - name: deb {{ elasticsearch_repo.pkg_repo_url }}/apt stable main
    - gpgkey: {{ elasticsearch.gpg_key }}
    - refresh_db: True
    {% elif os_family == 'RedHat' %}
    - name: {{ name }}
    - baseurl: {{ elasticsearch_repo.pkg_repo_url }}/yum
    - gpgcheck: 1
    - enabled: 1
    {% endif %}
    - key_url: {{ elasticsearch.gpg_key }}
{% else %}
{% for name, version in elasticsearch.products.items() %}
configure_{{ name }}_package_repo:
  pkgrepo.managed:
    - humanname: {{ name }}
    {% if os_family == 'Debian' %}
    - name: deb {{ elasticsearch_repo.pkg_repo_base}}/{{ name }}/{{ version }}/{{ elasticsearch.pkg_repo_suffix}} stable main
    - refresh_db: True
    {% elif os_family == 'RedHat' %}
    - name: {{ name }}
    - baseurl: {{ elasticsearch_repo.pkg_repo_base}}/{{ name }}/{{ version }}/{{ elasticsearch.pkg_repo_suffix}}
    - gpgcheck: 1
    - enabled: 1
    {% endif %}
    - key_url: {{ elasticsearch.gpg_key }}
{% endfor %}
{% endif %}

{% if osfullname == 'Debian' %}
configure_openjdk_repo:
    pkgrepo.managed:
    - humanname: 'OpenJDK'
    - name: {{ elasticsearch.openjdk_repo }}
    - enabled: True
    - refresh_db: True
    - require_in:
        - install_pkg_dependencies
{% endif %}
