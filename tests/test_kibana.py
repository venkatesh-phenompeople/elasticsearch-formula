import pytest


@pytest.mark.kibana
def test_kibana_repository_configured(SystemInfo, File):
    distro = SystemInfo.distribution
    if distro in ['ubuntu', 'debian']:
        assert File('/etc/apt/sources.list').contains(
            'packages.elastic.co/kibana')
    if distro in ['redhat', 'centos', 'fedora']:
        assert File('/etc/yum.repos.d/kibana.repo').exists


@pytest.mark.kibana
def test_dependencies_installed(Package):
    assert Package('nginx').is_installed


@pytest.mark.kibana
def test_kibana_installed(Package):
    assert Package('kibana').is_installed


@pytest.mark.kibana
def test_kibana_running(Service, Socket):
    kibana = Service('kibana')
    assert kibana.is_running
    assert kibana.is_enabled
    assert Socket('tcp://127.0.0.1:5601').is_listening


@pytest.mark.kibana
def test_nginx_running(File, Socket, Service):
    assert File('/etc/nginx/sites-enabled/kibana').exists
    nginx = Service('nginx')
    assert nginx.is_running
    assert nginx.is_enabled
    assert Socket('tcp://80').is_listening
    assert Socket('tcp://443').is_listening


@pytest.mark.kibana
def test_ssl_directory(File):
    assert File('/etc/salt/ssl/certs').exists
    assert File('/etc/salt/ssl/certs').is_directory


@pytest.mark.kibana
def test_kibana_env(File, SystemInfo):
    if SystemInfo.distribution == 'ubuntu':
        f = File('/etc/init.d/kibana')
    else:
        f = File('/etc/systemd/system/kibana.service')
    assert f.contains('NODE_OPTIONS=--max-old-space-size')
