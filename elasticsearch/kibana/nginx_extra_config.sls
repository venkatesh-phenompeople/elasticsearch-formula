{% from 'elasticsearch/kibana/map.jinja' import kibana with context %}

{% for file_details in kibana.get('nginx_extra_files', []) %}
add_file_{{ file_details.name }}:
  file.managed:
    - name: {{ file_details.path }}
    - contents: {{ file_details.contents }}
    - require_in:
        - file: add_extra_config_to_nginx
{% endfor %}

add_extra_config_to_nginx:
  file.blockreplace:
    - name: {{ kibana.nginx_site_path }}/kibana
    - marker_start: '# start_extra_configs'
    - marker_end: '# end_extra_configs'
    - source: {{ kibana.nginx_extra_config_template_source }}
    {% if kibana.get('nginx_extra_config_source_hash') %}
    - source_hash: {{ kibana.nginx_extra_config_source_hash }}
    {% endif %}
    - template: jinja
    - context:
        dict_config: {{ kibana.get('nginx_extra_config_dict', {}) }}
        list_config: {{ kibana.get('nginx_extra_config_list', []) }}
