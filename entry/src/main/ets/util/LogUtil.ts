
import { FaultLogger } from '@kit.PerformanceAnalysisKit'

export class LogUtil {
  static isLog: boolean = true
  static tag: string= 'ASR - '
  /**
   * debug log
   * @param message
   */
  static d(message: string) {
    if (LogUtil.isLog) {
      console.debug(LogUtil.tag+message)
    }
  }

  /**
   * info log
   * @param message
   */
  static i(message: string) {
    if (LogUtil.isLog) {
      console.info(LogUtil.tag+message)
    }
  }

  /**
   * error log
   * @param message
   */
  static e(message: string) {
    if (LogUtil.isLog) {
      console.error(LogUtil.tag+message)
    }
  }

  /**
   * warn log
   * @param message
   */
  static w(message: string) {
    if (LogUtil.isLog) {
      console.warn(LogUtil.tag+message)
    }
  }

}

export default  LogUtil