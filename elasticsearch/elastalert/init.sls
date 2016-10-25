{% from "elasticsearch/elastalert/map.jinja" import elastalert, elastalert_init with context %}

include:
  - elasticsearch.elastalert.service
  - elasticsearch.elastalert.config

install_elastalert_os_package_dependencies:
  pkg.installed:
    - pkgs: {{ elastalert.pkgs }}

install_elastalert_package:
  pip.installed:
    - name: elastalert
    - upgrade: True
    - require:
        - pkg: install_elastalert_os_package_dependencies
    - require_in:
        - service: elastalert_service_running

create_elastalert_control_script:
  file.managed:
    - name: /usr/local/bin/elastalert.sh
    - source: salt://elasticsearch/elastalert/files/elastalert.sh
    - mode: 0755

define_elastalert_init_service:
  file.managed:
    - name: {{ elastalert_init.init_file }}
    - source: {{ elastalert_init.init_source }}
    - require:
        - file: create_elastalert_control_script
    - require_in:
        - service: elastalert_service_running

{% if elastalert.create_index %}
{% set ssl_arg = '--ssl' if elastalert.settings.use_ssl else '--no-ssl' %}
{% set auth_arg = '' if elastalert.settings.get('es_password') else '--no-auth' %}
generate_elastalert_status_index:
  cmd.run:
    - name: >-
        /usr/local/bin/elastalert-create-index
        --host {{ elastalert.settings.es_host }}
        --port {{ elastalert.settings.es_port }}
        {{ ssl_arg }} {{ auth_arg }}
        --url-prefix {{ elastalert.settings.get("es_url_prefix", "''") }}
        --index {{ elastalert.settings.writeback_index }}
        --old-index {{ elastalert.settings.get("old_writeback_index", "''") }}
{% endif %}
