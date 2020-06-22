import os

import requests
import pytest


LOCAL_HOST_PORTAL = "https://mini-corezilla.pentium.network"
TOKEN = None


def _do_login(host, login_username, login_password):
    url = os.path.join(host, "api", "account", "pwd", "login")
    print(url)
    resp = requests.post(
        url=url,
        headers={"Content-Type": "application/json"},
        json={"email": login_username, "password": login_password},
    )
    return resp.text.strip()


def pytest_addoption(parser):
    parser.addoption(
        "--do_login", action="store_true", default=False, help="do login into host"
    )
    parser.addoption(
        "--host",
        action="store",
        default=LOCAL_HOST_PORTAL,
        help="portal url, e.g. https://your-portal.domain",
    )
    parser.addoption("--login_username", action="store")
    parser.addoption("--login_password", action="store")


@pytest.fixture(scope="session", autouse=True)
def do_login(request):
    return request.config.getoption("--do_login")


@pytest.fixture(scope="session", autouse=True)
def host(request):
    return request.config.getoption("--host")


@pytest.fixture(scope="session", autouse=True)
def login_username(request):
    return request.config.getoption("--login_username")


@pytest.fixture(scope="session", autouse=True)
def login_password(request):
    return request.config.getoption("--login_password")


@pytest.fixture(scope="session", autouse=True)
def token(do_login, host, login_username, login_password):
    global TOKEN
    if do_login:
        if TOKEN:
            return TOKEN
        TOKEN = _do_login(host, login_username, login_password)
        print(f"token: {TOKEN}")
        return TOKEN
    return ""


@pytest.fixture(scope="session", autouse=True)
def configure_environ(host):
    # old_os_enrivon = os.environ
    setattr(os, "environ", {"PN_GLOBAL_ROUTER": host})
    print(f">>> conftest: {os.environ}")
