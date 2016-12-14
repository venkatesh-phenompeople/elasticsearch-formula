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
  {% if kibana.es_client_node %}
  - elasticsearch.conf
  {% endif %}
  - elasticsearch.repository

install_kibana:
  pkg.installed:
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

{% if kibana.ssl.get('cert_source') or kibana.ssl.get('cert_contents') %}
setup_kibana_ssl_cert:
  file.managed:
    - name: {{ kibana.nginx_config.cert_path }}
    {% if kibana.ssl.get('cert_source') %}
    - source: {{ kibana.ssl.cert_source }}
    {% elif kibana.ssl.get('cert_contents') %}
    - contents: |
        {{ kibana.ssl.cert_contents | indent(8) }}
    {% endif %}
    - makedirs: True

setup_kibana_ssl_key:
  file.managed:
    - name: {{ kibana.nginx_config.key_path }}
    {% if kibana.ssl.get('key_source') %}
    - source: {{ kibana.ssl.key_source }}
    {% elif kibana.ssl.get('key_contents') %}
    - contents: |
        {{ kibana.ssl.key_contents | indent(8) }}
    {% endif %}
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

{% if salt.grains.get('init') == 'systemd' %}
add_node_environment_variables:
  file.managed:
    - name: /etc/systemd/system/kibana.service.d/kibana_env.conf
    - makedirs: True
    - contents: |
        [Service]
        {% for env in kibana.kibana_env %}
        Environment='{{ env }}'
        {% endfor %}

reload_kibana_systemd_units:
  cmd.wait:
    - name: systemctl daemon-reload
    - watch:
        - file: add_node_environment_variables
{% elif salt.grains.get('init') == 'upstart' %}
add_node_environment_variables:
  file.blockreplace:
    - name: /etc/init.d/kibana
    - marker_start: '  # Setup any environmental stuff beforehand'
    - marker_end: '  # Run the program!'
    - content: |
        {% for env in kibana.kibana_env %}
        export {{ env }}
        {% endfor %}
{% endif %}

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
