{% from "elasticsearch/kibana/map.jinja" import kibana, kibana_conf with context %}
{% from "elasticsearch/map.jinja" import elasticsearch with context %}

include:
    - .service

create_kibana_directory:
  file.directory:
    {% if elasticsearch.elastic_stack %}
    - name: /etc/kibana
    {% else %}
    - name: /opt/kibana/config
    {% endif %}
    - makedirs: True

configure_kibana:
  file.managed:
    {% if elasticsearch.elastic_stack %}
    - name: /etc/kibana/kibana.yml
    {% else %}
    - name: /opt/kibana/config/kibana.yml
    {% endif %}
    - contents: |
        {{ kibana_conf.config | yaml(False) | indent(8) }}
    - require:
        - file: create_kibana_directory

ensure_kibana_ssl_directory:
  file.directory:
    - name: {{ kibana.ssl_directory }}
    - makedirs: True

{% if kibana.ssl.get('cert_source') %}
setup_kibana_ssl_cert:
  file.managed:
    {% if elasticsearch.elastic_stack %}
    - name: {{ kibana_conf.nginx_config.server.ssl.certificate }}
    {% else %}
    - name: {{ kibana_conf.nginx_config.cert_path }}
    {% endif %}
    - source: {{ kibana.ssl.cert_source }}
    - makedirs: True

setup_kibana_ssl_key:
  file.managed:
    {% if elasticsearch.elastic_stack %}
    - name: {{ kibana_conf.nginx_config.server.ssl.key }}
    {% else %}
    - name: {{ kibana.nginx_config.key_path }}
    {% endif %}
    - source: {{ kibana.ssl.key_source }}
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
        config: {{ kibana_conf.nginx_config }}
        ssl_directory: {{ kibana.ssl_directory }}
        kibana_config: {{ kibana_conf.config }}
    - require:
        - cmd: generate_nginx_dhparam
        - module: setup_kibana_ssl_cert

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