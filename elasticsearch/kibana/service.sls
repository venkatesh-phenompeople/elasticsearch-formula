kibana_service:
  service.running:
    - name: kibana
    - enable: True

kibana_nginx_service:
  service.running:
    - name: nginx
    - enable: True