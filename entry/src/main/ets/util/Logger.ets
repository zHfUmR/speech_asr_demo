

import { hilog } from '@kit.PerformanceAnalysisKit';

/**
 *static info(TAG: string,arg1: string) {
 throw new Error('Method not implemented.');
 }
 Common log for all features.
 */
export class Logger {
  private domain: number;
  private prefix: string;
  private format: string = '%{public}s, %{public}s';

  constructor(prefix: string) {
    this.prefix = prefix;
    this.domain = 0xFF00;
  }

  public debug(...args: string[]): void {
    hilog.debug(this.domain, this.prefix, this.format, args);
  }

 public  info(...args: string[]): void {
    hilog.info(this.domain, this.prefix, this.format, args);
  }

  public warn(...args: string[]): void {
    hilog.warn(this.domain, this.prefix, this.format, args);
  }

  public error(...args: string[]): void {
    hilog.error(this.domain, this.prefix, this.format, args);
  }

  public fatal(...args: string[]): void {
    hilog.fatal(this.domain, this.prefix, this.format, args);
  }

  public isLoggable(level: number): void {
    hilog.isLoggable(this.domain, this.prefix, level);
  }
}

const  logger = new Logger('[Picker]');

export default logger

