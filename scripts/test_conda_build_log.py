import pytest
import log_parser

import os


def parse_log(logname):
    full_logname = os.path.join(os.path.split(os.path.abspath(__file__))[0],
                           logname)
    gen = list(log_parser.read_log_from_script(full_logname))
    parsed = {built_name: log_parser.parse_conda_build(lines) for name,
              built_name, lines in gen}
    return parsed

@pytest.fixture
def default_log():
    return parse_log('build.log')


def test_default_log_loader(default_log):
    # make sure that we have at least one thing that was parsed
    assert len(default_log) >= 1

def test_parse_init(default_log):
    # make sure we are getting the build command out of every single entry
    for pkg_name, parsed in default_log.items():
        parsed_init = log_parser.parse_init(parsed['init'])
        assert 'build_command' in parsed_init
        assert 'err' in parsed_init

def test_parse_build(default_log):
    # make sure we are getting either an error or the build string out of the
    # build section
    for pkg_name, parsed in default_log.items():
        if 'build' not in parsed:
            # not all packages will successfully build
            continue
        # if there is a build section, then parse it
        parsed_build = log_parser.parse_build(parsed['build'])
        if parsed_build['built_name'] == 'failed':
            assert parsed_build['err'] != []
        else:
            assert parsed_build['err'] == []


def test_parse_upload(default_log):
    # Make sure that auto_upload is always set to False
    for pkg_name, parsed in default_log.items():
        if 'upload' not in parsed:
            continue

        parsed_upload = log_parser.parse_upload(parsed['upload'])
        assert not parsed_upload['auto_upload']
        assert 'err'


def test_parse_bad_test_requires():
    parsed = parse_log('bad_import_requires.log')
    for pkg_name, grouped in parsed.items():
        parsed_test = log_parser.parse_test(grouped['test'])
        assert len(parsed_test['err']) > 0
        err = '\n'.join(parsed_test['err'][0])
        assert 'No packages found' in err

