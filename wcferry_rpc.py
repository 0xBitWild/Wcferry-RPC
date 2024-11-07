"""WcferryRPC 模块提供了与 SDK 交互的接口，用于管理微信相关功能的 RPC 服务。"""

import os
import time
import signal
import atexit
import ctypes
import logging
from pathlib import Path

# 配置日志记录，将日志写入到 app.log 文件中
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s %(levelname)s %(message)s',
    handlers=[
        logging.StreamHandler()
    ]
)

logger = logging.getLogger(__name__)


class WcferryRPC:
    """WcferryRPC 类用于管理 SDK 的初始化、运行和清理操作"""

    def __init__(self, port=10086):

        self.sdk = None
        self.port = port
        self.sdk_path = Path(__file__).parent.resolve() / "sdk"

        # 注册清理函数
        atexit.register(self._cleanup)
        signal.signal(signal.SIGINT, self._cleanup)

    def _cleanup(self):
        """清理 SDK 资源"""
        if self.sdk:
            if self.sdk.WxDestroySDK() != 0:
                logger.error("SDK 退出失败！")
        os._exit(-1)

    def initialize(self):
        """初始化 SDK"""
        try:
            # 加载 sdk.dll
            self.sdk = ctypes.cdll.LoadLibrary(f"{self.sdk_path}/sdk.dll")
            logging.info('SDK 初始化...')
            if self.sdk.WxInitSDK(True, self.port) != 0:
                logging.error('SDK 初始化失败！')
                self._cleanup()
            logger.info('SDK 初始化成功，rpc调用地址为：tcp://0.0.0.0:%s', self.port)
        except OSError as e:
            logger.error('SDK 初始化异常: %s', e)
            self._cleanup()

    def _main_loop(self):
        """主循环逻辑"""
        try:
            while True:
                time.sleep(1)
        except (KeyboardInterrupt, SystemError, OSError) as e:
            logger.error('循环异常: %s', e)
            self._cleanup()

    @classmethod
    def run(cls):
        """运行主循环"""
        wcferry_rpc = cls()
        while True:
            try:
                wcferry_rpc.initialize()
                wcferry_rpc._main_loop()
            except (OSError, RuntimeError) as e:
                logger.error('主循环异常: %s', e)
                time.sleep(5)  # 等待一段时间后重试


if __name__ == "__main__":

    WcferryRPC.run()
