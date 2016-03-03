"""Use testinfra and py.test to verify formula works properly"""

def test_elasticsearch_repository_configured(SystemInfo, File):
    distro = SystemInfo.distribution
    if distro in ['ubuntu', 'debian']:
        assert File('/etc/apt/sources.list').contains('packages.elastic.co')
    if distro in ['redhat', 'centos', 'fedora']:
        assert File('/etc/yum.repos.d/elasticsearch.repo').exists


def test_elasticsearch_installed(Package):
    assert Package('elasticsearch').is_installed


def test_elasticsearch_running(Service):
    es = Service('elasticsearch')
    assert es.is_running
    assert es.is_enabled


def test_correct_io_scheduler(Command):
    dev_names = [dev.strip() for dev in Command.check_output(
        'echo "$(salt-call --local grains.get SSDs)" | sed 1d').split('\n')
                 if dev]
    for dev in dev_names:
        assert Command(
            'cat /sys/block/{0}/queue/scheduler'.format(dev.strip())) == 'noop'


def test_correct_heap_size(File, Command, SystemInfo):
    max_heap = int(
        Command.check_output('cat /proc/meminfo | head -1 | awk \'{print $2}\'')
    ) / 1024 // 2
    distro = SystemInfo.distribution
    if distro in ['ubuntu', 'debian']:
        fname = File('/etc/default/elasticsearch')
        assert fname.exists
    if distro in ['redhat', 'centos', 'fedora']:
        fname = File('/etc/sysconfig/elasticsearch')
        assert fname.exists
    assert fname.contains('ES_HEAP_SIZE={0}m' .format(max_heap))


def test_swappiness_set(Command, File):
    assert not File('/etc/fstab').contains('swap')


def test_file_descriptor_limit(Command, File):
    fname = File('/etc/sysctl.conf')
    assert int(Command.check_output('cat /proc/sys/fs/file-max')) == 100000
    assert int(Command.check_output('cat /proc/sys/vm/max_map_count')) == 262144
    assert fname.contains('fs.file_max')
    assert fname.contains('vm.max_map_count')


def test_elasticsearch_configuration(File):
    conf = File('/etc/elasticsearch/elasticsearch.yml')
    assert conf.exists
    assert conf.contains('cluster.name: elasticsearch_cluster')
