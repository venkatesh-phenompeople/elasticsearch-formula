import pytest


@pytest.mark.nginx
def test_nginx_extra_config_lines(File):
    assert File('/etc/nginx/sites-enabled/kibana').contains('auth_basic on;')


@pytest.mark.nginx
def test_nginx_extra_file(File):
    assert File('/etc/nginx/kibana_users').exists
    assert File('/etc/nginx/kibana_users').contains('kibana:YT6iPwvMfqU02')
