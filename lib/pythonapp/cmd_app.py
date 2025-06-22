# -*-coding:utf-8-*-
import time
import os
import threading
import logging
import io
import sys
import signal


class AsyncThreadingManager(threading.Thread):
    """
    __proxies: Proxy to use requests to send HTTP requests (optional)
    """

    version = "54b602d334dbd7fa098ee5301611eda1776f6f39"

    def __init__(
        self,
    ) -> None:
        super().__init__()
        self.daemon = True

    def run(self):
        # try:
        self._run()

    # except Exception as e:
    #     self.exit_code = 1
    #     self.exception = e

    def _run(self):
        # logger.info("初始化爬虫......")

        time.sleep(10)

        if self.ifstop:
            sys.stdout.write("OVER\n")
            return

        # 退出程序
        sys.stdout.write("OVER\n")
        sys.stdout.flush()
        return

    def stop(self):
        self.ifstop = True
        return 0


def terminate_signal_handler(signal, frame):
    # logger.info("手动终止程序,正在停止......")
    manager.stop()
    while manager.is_alive():
        time.sleep(0.2)
    # logger.info("程序终止")
    sys.exit(0)


if __name__ == "__main__":
    import argparse

    parser = argparse.ArgumentParser()
    parser.add_argument("--configfile", nargs="?", default="jsons/config.json")
    args = parser.parse_args()
    # 改变标准输出的默认编码
    sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding="utf8")

    config_save_path = os.path.join(args.configfile)

    # 实例化爬虫管理类
    manager = AsyncThreadingManager()

    # 终止信号处理
    signal.signal(signal.SIGINT, terminate_signal_handler)
    signal.signal(signal.SIGTERM, terminate_signal_handler)

    # 启动爬虫
    manager.start()
    # 等待程序结束/终止信号
    while True:
        _signal = sys.stdin.readline().strip()
        sys.stdout.write(f"Receive signal: {_signal}")
        # logger.info(_signal)
        # 终止信号
        if _signal == "STOP":
            terminate_signal_handler(0, 0)
        elif _signal == "OVER":
            sys.stdout.write("5")
            # sys.exit(0)
            """
            # 数据库操作
            elif _signal.find('DATA')>=0:
                search = _signal.split('||')[1]
                if search:
                    pass
                else:
                    sys.stdout.write('SENDSTART\n')
                    sys.stdout.flush()
                    # print('SENDSTART',flush=True)
                    time.sleep(0.01)
                    # data = asyncio.get_event_loop().run_until_complete(asyncio.ensure_future(asyncbackupcollection.find(
                    #     {'id': {"$exists": "true"}}).sort("id", -1).to_list(None)))
                    for _data in backupcollection.find({'id': {"$exists": "true"}},{"_id": 0}).sort("id", -1):
                        sys.stdout.write(json.dumps(_data)+'||')
                    sys.stdout.flush()
                    time.sleep(0.01)
                    sys.stdout.write('SENDEND')
                    sys.stdout.flush()
                    # logger.info("DATA||{}".format(data))
            """
        # 网络操作
        elif _signal.find("NETWORK") >= 0:
            pass
