# flake8: noqa
import json
import uuid

import pytest
import pnlogging
from blcks import blcks, config
import handler
from handler import main, FAAS_METHOD_NAME

blcks._logger = pnlogging.getLogger(config.MODULE_NAME)

logger = None
fp = None


@pytest.fixture(scope="session", autouse=True)
def init_logger():
    global logger
    if logger is None:
        logger = pnlogging.getLogger(config.MODULE_NAME)
    return logger


@pytest.fixture(scope="session", autouse=True)
def init_fp(request):
    global fp

    def fin():
        print(f"teardown fp")
        fp.close()

    if fp is None:
        fp = open(pnlogging.PN_LOG_PATH_DFL, "a+")
        # close fp while testing complete
        request.addfinalizer(fin)


# check last log with level and key, value
def _check_result(lvl, **kwargs):
    for h in logger.logger.handlers:
        h.flush()

    res = fp.read()
    print(f"res: {res}")
    res = res.strip()
    ress = res.split("\n")
    print(f">> {ress}")
    for r in ress:
        json_res = json.loads(r)
        assert json_res["level"] == lvl
        for k, v in kwargs.items():
            assert json_res[k] == v


# define which action is to check in blcks
@pytest.fixture(scope="session")
def headers(token):
    print("token: ", token)
    return {"Authorization": token}


@pytest.fixture(scope="session")
def bodyDict():
    # input key and values, for this example, two input key as define
    # key2 and cdnList
    return {"key2": "value2", "cdnList": [{"id": 12345}, {"id": 23456}]}


@pytest.fixture(scope="session")
def body(bodyDict):
    return json.dumps(bodyDict)


@pytest.fixture(scope="session")
def taskId():
    return str(uuid.uuid4())


@pytest.fixture(scope="session")
def token_detail(token):
    return {"userId": "iamuserid", "account": "iamaccount", "ip": "1.2.3.4"}


@pytest.fixture(scope="session")
def context():
    return {"resourceIds": []}


@pytest.fixture(scope="session")
def eventStr(token_detail, body, taskId, headers, context):
    return json.dumps(
        {
            "action": FAAS_METHOD_NAME,
            "token": token_detail,
            "body": body,
            "taskId": taskId,
            "headers": headers,
            "context": context,
        }
    )


@pytest.fixture(scope="session")
def event(eventStr):
    e = json.loads(eventStr)
    e["context"]["resourceIds"] = []
    e["body"] = json.dumps(
        {"headers": ["content-type: application/json"], "message": "hello"}
    )
    return json.dumps(e)


# ========== ADD YOUR TESTING CASES BELOW =======
def test_main(event):
    resp = main(event, None)
    assert resp["code"] == 0
    assert resp["msg"] == "hello"
