{% from "elasticsearch/elastalert/map.jinja" import elastalert, elastalert_init with context %}

include:
  - elasticsearch.elastalert.service
  - elasticsearch.elastalert.configure

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