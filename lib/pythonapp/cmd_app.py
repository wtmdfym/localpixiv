# -*-coding:utf-8-*-
import time
import asyncio
import threading
import logging
import io
import sys
import signal
from motor import motor_asyncio
import pymongo
from infoRecorders import *
from downloader import Analyzer
from Tool import *


class AsyncThreadingManager(threading.Thread):
    """
    __proxies: Proxy to use requests to send HTTP requests (optional)
    """

    version = "54b602d334dbd7fa098ee5301611eda1776f6f39"

    def __init__(
        self, config_dict: dict, config_save_path, logger: logging.Logger
    ) -> None:
        super().__init__()
        self.daemon = True
        # _, js = self.loop.run_until_complete(asyncio.ensure_future(self.clientpool.send_get_request('https://www.pixiv.net/ajax/user/25170019/profile/all?lang=zh&version=54b602d334dbd7fa098ee5301611eda1776f6f39', '1')))
        # print(js)
        # exit(0)

    def run(self):
        # try:
        self._run()

    # except Exception as e:
    #     self.exit_code = 1
    #     self.exception = e

    def _run(self):
        logger.info("初始化爬虫......")

        # 初始化协程事件循环
        logger.info("初始化协程事件循环......")
        loop = asyncio.new_event_loop()
        asyncio.set_event_loop(loop)

        # 初始化数据库
        logger.info("初始化数据库......")
        asyncclient = motor_asyncio.AsyncIOMotorClient("localhost", 27017, io_loop=loop)
        asyncdb = asyncclient["pixiv"]
        asyncbackupcollection = asyncclient["backup"]["backup of pixiv infos"]
        # 初始化配置信息
        logger.info("初始化配置信息......")
        self.ifstop = False
        self.config_dict = config_dict
        self.config_save_path = config_save_path
        self.loop = loop
        self.asyncdb = asyncdb
        self.asyncbackup_collection = asyncbackupcollection
        self.logger = logger
        self.clientpool = clientPool

        # 设置最大并发量
        self.semaphore = asyncio.Semaphore(self.config_dict["semaphore"])
        self.logger.info("初始化完成!")
        """try:
            loop = asyncio.get_event_loop()
        except RuntimeError:
            loop = asyncio.new_event_loop()
            asyncio.set_event_loop(loop)"""

        # 判断时间间隔
        newtime = time.strftime("%Y%m%d%H%M%S")
        if compare_datetime(self.config_dict["last_record_time"], newtime):
            ### 获取关注的作者
            if self.ifstop:
                sys.stdin.write("OVER\n")
                self.loop.stop()
                return

            self.followings_recorder = FollowingsRecorder(
                self.clientpool.myclient,
                self.asyncdb,
                self.logger,
                self.semaphore,  # , self.progress_signal
            )
            self.followings_recorder.set_version(self.version)
            # success = self.loop.run_until_complete(asyncio.ensure_future(
            #     self.followings_recorder.bookmarked_work_fetcher()))
            success = self.loop.run_until_complete(
                asyncio.ensure_future(self.followings_recorder.following_work_fetcher())
            )
            # success = await self.followings_recorder.following_work_fetcher()
            if not success:
                sys.stdout.write("OVER\n")
                self.loop.stop()
                return
            del self.followings_recorder

            ### 获取关注的作者的信息
            if self.ifstop:
                self.loop.stop()
                sys.stdout.write("OVER\n")
                return
            self.info_getter = WorkInfoRecorder(
                self.clientpool,
                self.config_dict["download_type"],
                self.asyncdb,
                self.asyncbackup_collection,
                self.logger,
                self.semaphore,
                # self.progress_signal
            )
            self.info_getter.set_version(self.version)
            success = self.loop.run_until_complete(
                asyncio.ensure_future(self.info_getter.start_get_info())
            )
            # success = await self.info_getter.start_get_info()
            if success:
                self.config_dict.update({"last_record_time": newtime})
                ConfigSetter.set_config(self.config_save_path, self.config_dict)
            del self.info_getter
        else:
            self.logger.info("最近已获取,跳过")
        # exit(0)

        ### 下载作品
        if self.ifstop:
            self.loop.stop()
            sys.stdout.write("OVER\n")
            return
        self.downloader = Analyzer(
            self.config_dict["host_path"],
            self.clientpool,
            self.config_dict["download_type"],
            self.semaphore,
            self.asyncbackup_collection,
            self.asyncdb["All Followings"],
            self.logger,
        )
        self.loop.run_until_complete(
            asyncio.ensure_future(self.downloader.start_download())
        )
        # await self.downloader.start_following_download()
        del self.downloader

        # 退出程序
        sys.stdout.write("OVER\n")
        sys.stdout.flush()
        self.loop.stop()
        return

    def stop(self):
        self.ifstop = True
        try:
            self.followings_recorder.stop_recording()
        except AttributeError:
            pass
        try:
            self.info_getter.stop_getting()
        except AttributeError:
            pass
        try:
            self.downloader.stop_downloading()
        except AttributeError:
            pass
        return 0


def terminate_signal_handler(signal, frame):
    logger.info("手动终止程序,正在停止......")
    manager.stop()
    while manager.is_alive():
        time.sleep(0.2)
    logger.info("程序终止")
    sys.exit(0)


def main():
    import argparse

    parser = argparse.ArgumentParser()
    parser.add_argument(
        "--configfile", nargs="?", default="jsons/default_config.json", required=True
    )
    args = parser.parse_args()

    sys.stdout = io.TextIOWrapper(
        sys.stdout.buffer, encoding="utf8"
    )  # 改变标准输出的默认编码
    ### 日志
    logging.basicConfig(
        format="%(asctime)s => [%(levelname)s] - %(message)s",
        datefmt="%Y-%m-%d %H:%M:%S",
        stream=sys.stdout,
        encoding="utf-8",
        level=logging.INFO,
    )
    logger = logging.getLogger("basic_logger")

    # ====================================
    logger.info("开始初始化程序......")

    # 初始化设置信息
    logger.info("读取配置文件......")
    config_save_path = os.path.join(args.configfile)
    config_dict = ConfigSetter.get_config(config_save_path)
    """
    app_path = os.path.dirname(__file__)
    default_config_save_path = os.path.join(os.path.abspath(app_path), "default_config.json")
    config_save_path = os.path.join(os.path.abspath(app_path), "config.json")
    config_dict = ConfigSetter.get_config(config_save_path, default_config_save_path)
    """
    """
    # 初始化协程事件循环
    logger.info("初始化协程事件循环......")
    loop = asyncio.new_event_loop()
    # asyncio.set_event_loop(loop)

    # 初始化数据库
    logger.info("初始化数据库......")
    asyncclient = motor_asyncio.AsyncIOMotorClient('localhost', 27017, io_loop=loop)
    asyncdb = asyncclient["pixiv"]
    asyncbackupcollection = asyncclient["backup"]["backup of pixiv infos"]
    """
    # 初始化连接池
    clientPool = ClientPool(config_dict, config_save_path, logger)
    # 实例化爬虫管理类
    manager = AsyncThreadingManager(config_dict, config_save_path, logger)

    # 终止信号处理
    signal.signal(signal.SIGINT, terminate_signal_handler)
    signal.signal(signal.SIGTERM, terminate_signal_handler)

    # 启动爬虫
    manager.start()
    # t = threading.Thread(target=manager.run)
    # t.start()
    # future = asyncio.ensure_future(manager.run())

    asyncclient = motor_asyncio.AsyncIOMotorClient("localhost", 27017)
    asyncdb = asyncclient["pixiv"]
    asyncbackupcollection = asyncclient["backup"]["backup of pixiv infos"]
    # 等待程序结束/终止信号
    while True:
        _signal = sys.stdin.readline().strip()
        # print(_signal)
        # 终止信号
        if _signal == "STOP":
            terminate_signal_handler(0, 0)
        elif _signal == "OVER":
            print(5)
            sys.exit(0)
        # 数据库操作
        elif _signal.find("DATA"):
            data = asyncbackupcollection.find({"id": {"$exists": "true"}}).sort(
                "id", -1
            )
        # 网络操作
        elif _signal.find("NETWORK"):
            pass


if __name__ == "__main__":
    import argparse, json

    parser = argparse.ArgumentParser()
    parser.add_argument("--configfile", nargs="?", default="jsons/config.json")
    args = parser.parse_args()

    sys.stdout = io.TextIOWrapper(
        sys.stdout.buffer, encoding="utf8"
    )  # 改变标准输出的默认编码
    ### 日志
    logging.basicConfig(
        format="%(asctime)s => [%(levelname)s] - %(message)s",
        datefmt="%Y-%m-%d %H:%M:%S",
        stream=sys.stdout,
        encoding="utf-8",
        level=logging.INFO,
    )
    logger = logging.getLogger("basic_logger")

    # ====================================
    logger.info("开始初始化程序......")
    # """
    # 初始化设置信息
    logger.info("读取配置文件......")
    config_save_path = os.path.join(args.configfile)
    config_dict = ConfigSetter.get_config(config_save_path)
    """
    app_path = os.path.dirname(__file__)
    default_config_save_path = os.path.join(os.path.abspath(app_path), "default_config.json")
    config_save_path = os.path.join(os.path.abspath(app_path), "config.json")
    config_dict = ConfigSetter.get_config(config_save_path, default_config_save_path)
    """
    """
    # 初始化协程事件循环
    logger.info("初始化协程事件循环......")
    loop = asyncio.new_event_loop()
    # asyncio.set_event_loop(loop)

    # 初始化数据库
    logger.info("初始化数据库......")
    asyncclient = motor_asyncio.AsyncIOMotorClient('localhost', 27017, io_loop=loop)
    asyncdb = asyncclient["pixiv"]
    asyncbackupcollection = asyncclient["backup"]["backup of pixiv infos"]
    """
    # 初始化连接池
    clientPool = ClientPool(config_dict, config_save_path, logger)
    # 实例化爬虫管理类
    manager = AsyncThreadingManager(config_dict, config_save_path, logger)

    # 终止信号处理
    signal.signal(signal.SIGINT, terminate_signal_handler)
    signal.signal(signal.SIGTERM, terminate_signal_handler)

    # 启动爬虫
    manager.start()
    # t = threading.Thread(target=manager.run)
    # t.start()
    # future = asyncio.ensure_future(manager.run())
    # """
    # asyncclient = motor_asyncio.AsyncIOMotorClient('localhost', 27017)
    # client = pymongo.MongoClient('localhost', 27017)
    # asyncdb = asyncclient["pixiv"]
    # asyncbackupcollection = asyncclient["backup"]["backup of pixiv infos"]
    # backupcollection = client["backup"]["backup of pixiv infos"]
    # logger.info('waiting...')
    # 等待程序结束/终止信号
    while True:
        _signal = sys.stdin.readline().strip()
        logger.info(_signal)
        # 终止信号
        if _signal == "STOP":
            terminate_signal_handler(0, 0)
        elif _signal == "OVER":
            logger.info(5)
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
