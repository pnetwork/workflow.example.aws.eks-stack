import time
from sqlalchemy import create_engine

from blcks import blcks

FAAS_METHOD_NAME = "mysqlserver"
logger = blcks.logger


@blcks
def main(event, context):
    pass


@blcks.script(FAAS_METHOD_NAME)
def process(url, username, password):
    result = {"code": 0, "status": "success", "result": None}
    # return result
    blcks.logger.info("1")
    eng = create_engine(
        f"mysql+pymysql://{username}:{password}@{url}",
        echo=True,
        encoding="utf-8",
        connect_args={"connect_timeout": 60},
    )
    blcks.logger.info("2")
    qry = eng.execute("SHOW DATABASES")
    blcks.logger.info("3")
    dbs = qry.fetchall()
    blcks.logger.info("4")
    # print(list(dbs))
    result["result"] = list()
    for rowproxy in dbs:
        (dbname,) = rowproxy
        result["result"].append(dbname)
    blcks.logger.info("5")
    blcks.logger.info(f"result: {result}")
    try:
        qry.close()
    except Exception:
        blcks.logger.exception("exception occurred")
    blcks.logger.info(f"6: {result}")
    return result
