{% from "elasticsearch/map.jinja" import elasticsearch with context %}

include:
  - .service
  - .repository

# Create folder and set permissions
{% set conf_dir = elasticsearch.conf_folder %}
{% set log_dir = elasticsearch.log_folder %}

{% for dir in (conf_dir, log_dir) %}
{% if dir %}
{{ dir }}:
  file.directory:
    - user: elasticsearch
    - group: elasticsearch
    - mode: 0700
    - makedirs: True
{% endif %}
{% endfor %}

# Update the I/O scheduler if using SSD to improve write throughput https://www.elastic.co/guide/en/elasticsearch/guide/current/hardware.html
{% for device_name in salt.grains.get('SSDs') %}
update_io_scheduler_for_{{device_name}}:
  cmd.run:
    - name: echo noop | tee /sys/block/{{ device_name }}/queue/scheduler
{% endfor %}

# Update Heap Size according to available RAM https://www.elastic.co/guide/en/elasticsearch/reference/current/heap-size.html
{% set heap_max = salt.grains.get('mem_total', 0) // 2 %}
{% set heap_size = heap_max if heap_max < 31744 else 31744 %}
{% if elasticsearch.version == '5.x' %}
config_jvm_options:
  file.replace:
  - name: '{{ elasticsearch.conf_folder }}/jvm.options'
  - pattern: '^-Xm[sx]\d\w'
  - repl: '#-Xm[sx]\d\w'

update_elasticsearch_heap_size:
  file.replace:
    - name: {{ elasticsearch.env_file }}
    - pattern: '^#ES_JAVA_OPTS='
    - repl: 'ES_JAVA_OPTS="-Xms{{ heap_size }}m -Xmx{{ heap_size }}m"'
    - append_if_not_found: True
    - watch_in:
        - service: elasticsearch

{% else %}
update_elasticsearch_heap_size:
  file.replace:
    - name: {{ elasticsearch.env_file }}
    - pattern: '#?ES_HEAP_SIZE=\d+\w+'
    - repl: 'ES_HEAP_SIZE={{ heap_size }}m'
    - append_if_not_found: True
    - watch_in:
        - service: elasticsearch
{% endif %}

# Configure/disable swappiness https://www.elastic.co/guide/en/elasticsearch/reference/current/setup-configuration-memory.html
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

# Up the count for file descriptors for Lucene https://www.elastic.co/guide/en/elasticsearch/reference/current/file-descriptors.html
increase_file_descriptor_limit:
  cmd.run:
    - name: sysctl -w fs.file-max={{ elasticsearch.fd_limit }}
  file.append:
    - name: /etc/sysctl.conf
    - text: fs.file_max={{ elasticsearch.fd_limit }}
    - watch_in:
        - service: elasticsearch

# Increase limits of mmap counts https://www.elastic.co/guide/en/elasticsearch/reference/current/vm-max-map-count.html
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
    - contents: |
        {{ elasticsearch.configuration_settings | yaml(False) | indent(8) }}
    - makedirs: True
    - watch_in:
        - service: elasticsearch