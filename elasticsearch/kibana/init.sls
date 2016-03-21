{% from "elasticsearch/kibana/map.jinja" import kibana with context %}
{% set os_family = grains['os_family'] %}

install_kibana_dependencies:
  pkg.installed:
    - pkgs: {{ kibana.pkgs }}
    - require_in:
        - pkgrepo: configure_kibana_package_repo
    - reload_modules: True
    - update: True

include:
  - elasticsearch.repository
  {% if kibana.es_client_node %}
  - elasticsearch.conf
  {% endif %}

install_kibana:
  pkg.latest:
    - name: kibana
    - require:
        - pkgrepo: configure_kibana_package_repo

configure_kibana:
  file.managed:
    - name: /opt/kibana/config/kibana.yml
    - contents: |
        {{ kibana.config | yaml(False) | indent(8) }}

ensure_kibana_ssl_directory:
  file.directory:
    - name: {{ kibana.ssl_directory }}
    - makedirs: True

{% if kibana.nginx_config.get('cert_source') %}
setup_kibana_ssl_cert:
  file.managed:
    - name: {{ kibana.nginx_config.cert_path }}
    - source: {{ kibana.nginx_config.cert_source }}
    - makedirs: True

setup_kibana_ssl_key:
  file.managed:
    - name: {{ kibana.key_path }}
    - source: {{ kibana.key_source }}
    - makedirs: True
{% else %}
setup_kibana_ssl_cert:
  module.run:
    - name: tls.create_self_signed_cert
    - tls_dir: ssl
    - cacert_path: /etc/salt/
    - require:
        - file: ensure_kibana_ssl_directory
    {% for arg, val in salt.pillar.get('kibana:ssl:cert_params', {}).items() -%}
    - {{ arg }}: {{ val }}
    {% endfor -%}
{% endif %}

generate_nginx_dhparam:
  cmd.run:
    - name: openssl dhparam -out dhparam.pem 2048
    - cwd: {{ kibana.ssl_directory }}
    - unless: "[ -e {{ kibana.ssl_directory }}/dhparam.pem ]"
    - require:
        - file: ensure_kibana_ssl_directory

configure_kibana_nginx:
  file.managed:
    - name: {{ kibana.nginx_site_path }}/kibana
    - source: salt://elasticsearch/kibana/templates/nginx.conf
    - template: jinja
    - context:
        config: {{ kibana.nginx_config }}
        ssl_directory: {{ kibana.ssl_directory }}
        kibana_config: {{ kibana.config }}

remove_default_nginx_config:
  file.absent:
    - name: {{ kibana.nginx_site_path }}/default

kibana_service:
  service.running:
    - name: kibana
    - enable: True
    - watch:
        - file: configure_kibana

kibana_nginx_service:
  service.running:
    - name: nginx
    - enable: True
    - watch:
        - file: configure_kibana_nginx
