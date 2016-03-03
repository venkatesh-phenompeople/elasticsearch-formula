{% from "elasticsearch/map.jinja" import elasticsearch with context %}

include:
  - elasticsearch.repository

install_pkg_dependencies:
  pkg.installed:
    - names: {{ elasticsearch.pkgs }}
    - refresh: True

install_elasticsearch:
  pkg.installed:
    - name: elasticsearch
    - refresh: True
    - require:
        - pkgrepo: configure_elasticsearch_package_repo
        - pkg: install_pkg_dependencies


# Update the I/O scheduler if using SSD to improve write throughput https://www.elastic.co/guide/en/elasticsearch/guide/current/hardware.html
{% for device_name in salt.grains.get('SSDs') %}
update_io_scheduler_for_{{device_name}}:
  cmd.run:
    - name: echo noop | tee /sys/block/{{ device_name }}/queue/scheduler
{% endfor %}

# Update Heap Size according to available RAM https://www.elastic.co/guide/en/elasticsearch/guide/current/heap-sizing.html
{% set heap_max = salt.grains.get('mem_total', 0) // 2 or 1024 %}
{% set heap_size = heap_max if heap_max < 31744 else 31744 %}
update_elasticsearch_heap_size:
  file.replace:
    - name: {{ elasticsearch.env_file }}
    - pattern: '#?ES_HEAP_SIZE=\d+\w+'
    - repl: 'ES_HEAP_SIZE={{ heap_size }}m'
    - append_if_not_found: True
    - watch_in:
        - service: elasticsearch

# Configure/disable swappiness
{% if elasticsearch.disable_swap %}
disable_swap_on_elasticsearch_node:
  cmd.run:
    - name: swapoff -a
  file.line:
    - name: /etc/fstab
    - content: ''
    - match: swap
    - mode: Delete
    - watch_in:
        - service: elasticsearch
{% else %}
set_swapiness_for_elasticsearch_node:
  cmd.run:
    - name: sysctl -w vm.swappiness=1
  file.append:
    - name: /etc/sysctl.conf
    - text: vm.swappiness = 1
    - watch_in:
        - service: elasticsearch
{% endif %}

# Up the count for file descriptors for Lucene https://www.elastic.co/guide/en/elasticsearch/guide/current/_file_descriptors_and_mmap.html
increase_file_descriptor_limit:
  cmd.run:
    - name: sysctl -w fs.file-max={{ elasticsearch.fd_limit }}
  file.append:
    - name: /etc/sysctl.conf
    - text: fs.file_max={{ elasticsearch.fd_limit }}
    - watch_in:
        - service: elasticsearch

increase_max_map_count:
  cmd.run:
    - name: sysctl -w vm.max_map_count={{ elasticsearch.max_map_count }}
  file.append:
    - name: /etc/sysctl.conf
    - text: vm.max_map_count={{ elasticsearch.max_map_count }}
    - watch_in:
        - service: elasticsearch

configure_elasticsearch:
  file.managed:
    - name: /etc/elasticsearch/elasticsearch.yml
    - source: salt://elasticsearch/templates/conf.jinja
    - template: jinja
    - context:
        config: {{ elasticsearch.configuration_settings }}
    - watch_in:
        - service: elasticsearch

elasticsearch:
  service.running:
    - enable: True
