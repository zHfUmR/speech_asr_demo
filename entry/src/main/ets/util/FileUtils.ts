import common from '@ohos.app.ability.common';
import { fileIo, WriteOptions } from '@kit.CoreFileKit';
import { BusinessError } from '@ohos.base';
import LogUtil from './LogUtil';
import { util } from '@kit.ArkTS';


const TAG: string = 'FileUtil';
const ALBUMS: string[] = ['Pictures', 'Videos', 'Others'];
const BUFFER_SIZE = 4096;
const COMMON_FD = -1;
const MODE_READ_ONLY = 0;
const MODE_WRITE_ONLY = 1;
const MODE_READ_WRITE = 2;


class FileUtil {
    content: string = '';
    private commonFd: number = COMMON_FD;
    private fileSizeList: Array<number> = [];
    private fileNameList: Array<string> = [];
    private fileUriList: Array<string> = [];

    constructor() {
    }

    async writeContentToFile(uri: string, buffer: ArrayBuffer | string, cover: boolean = false) {
        LogUtil.i('mengx writeFileContent begin');

        let value = await fileIo.access(uri)

        if (!value || cover) {

            LogUtil.i('-----------------------------------------------------------------------no file, need create file');
            let file = fileIo.openSync(uri, fileIo.OpenMode.READ_WRITE | fileIo.OpenMode.CREATE);
            LogUtil.i('mengx writeFileContent file fd: ' + file.fd);

            if (typeof buffer === "string") {
                console.log("buffer is a string:", buffer);
                // 处理字符串类型
            } else if (typeof buffer === "object") {
                console.log("mengx buffer is an ArrayBuffer:", buffer);
            }

            try {
                let writeLen = fileIo.writeSync(file.fd, buffer);
                LogUtil.i('mengx writeFileContent write data to file succeed and size is:' + writeLen);
            } catch (error) {
                let code = (error as BusinessError).code;
                let message = (error as BusinessError).message;
                console.error(`mengx  promise getRawFd failed, error code: ${code}, message: ${message}.`);
            } finally {
                fileIo.closeSync(file);
            }
        }

    }


    writeBufferToFile(uri: string, buffer: ArrayBuffer) {
        LogUtil.i('mengx writeFileContent begin');
        let file = null
        try {
            file = fileIo.openSync(uri, fileIo.OpenMode.READ_WRITE | fileIo.OpenMode.CREATE);
            LogUtil.i('mengx writeFileContent file fd: ' + file.fd);
        }
        catch (error) {
            let code = (error as BusinessError).code;
            let message = (error as BusinessError).message;
            console.error(`mengx  promise fileIo.openSync failed, error code: ${code}, message: ${message}.`);
        }


        let fileSize = 0;
        let stat: fileIo.Stat = fileIo.statSync(uri)

        fileSize = stat.size
        console.info("----------------------------get file info succeed, the size of file is " + stat.size);

        try {

            let options: WriteOptions = {
                offset: fileSize ,
                length: buffer.byteLength
            }
            let writeLen = fileIo.writeSync(file.fd, buffer, options);
            LogUtil.i('mengx writeFileContent write data to file succeed and size is:' + writeLen);
        } catch (error) {
            let code = (error as BusinessError).code;
            let message = (error as BusinessError).message;
            console.error(`mengx  promise getRawFd failed, error code: ${code}, message: ${message}.`);
        } finally {
            fileIo.closeSync(file);
            LogUtil.i('mengx writeFileContent end');
        }

    }

    getMode(openFlag: number): number {
        let mode: number = 0;
        switch (openFlag) {
            case MODE_READ_ONLY:
                mode = fileIo.OpenMode.READ_ONLY; // r
                break;
            case MODE_WRITE_ONLY:
                mode = fileIo.OpenMode.WRITE_ONLY; // w
                break;
            case MODE_READ_WRITE:
                mode = fileIo.OpenMode.READ_WRITE; // rw
                break;
        }
        return mode;
    }

    myWriteSync(fd: number, content: string, isClose: boolean): void {
        try {
            let result = fileIo.writeSync(fd, content);
            LogUtil.i('myWriteSync: write result = ' + result);
        } catch (err) {
            LogUtil.e('myWriteSync： write failed with error:' + err);
        }
        if (isClose) {
            this.closeSync(fd);
            this.commonFd = COMMON_FD;
        } else {
            this.commonFd = fd;
        }
    }

    // sync-close
    closeSync(fd: number): void {
        try {
            fileIo.closeSync(fd);
            LogUtil.i('closeSync file finish.');
        } catch (err) {
            LogUtil.e('closeSync file error = ' + err);
        }
    }

    readFileContent(uri: string, isRead: boolean = true, isClose: boolean = true): string {
        let content = '';
        LogUtil.i('open path = ' + uri);
        let file: fileIo.File;
        if (isClose || this.commonFd === COMMON_FD) {
            try {
                file = fileIo.openSync(uri, fileIo.OpenMode.READ_ONLY);
                LogUtil.i('openReadSync: get fd success. fd = ' + file.fd);
                this.commonFd = file.fd;
            } catch (err) {
                LogUtil.e('openReadSync: open file failed. error = ' + err);
                return content;
            }
            if (file === undefined) {
                LogUtil.e('openReadSync: open file failed. file = undefined.');
                return content;
            }
        }
        if (isRead) {
            try {
                let buffer = new ArrayBuffer(BUFFER_SIZE);
                let readOut = fileIo.readSync(this.commonFd, buffer, {
                    offset: 0
                });
                content = this.bufferToString(buffer);
            } catch (err) {
                LogUtil.e('myReadSync: read error: ' + err);
                return content;
            }

            if (isClose) {
                this.closeSync(this.commonFd);
                this.commonFd = COMMON_FD;
            } else {
                this.commonFd = this.commonFd;
            }
        }
        return content;
    }

    myGetFileSize(uri: string, mode: number): number {
        let file = fileIo.openSync(uri, mode); // fs.OpenMode.READ_ONLY
        LogUtil.i('file fd: ' + file.fd);
        let stat = fileIo.statSync(file.fd);
        LogUtil.i('get file info succeed, the size of file is ' + stat.size);
        return stat.size;
    }

    bufferToString(buffer: ArrayBuffer): string {
        let textDecoder = util.TextDecoder.create('utf-8', { ignoreBOM: true })
        let resultPut = textDecoder.decodeWithStream(new Uint8Array(buffer), {
            stream: true
        });
        return resultPut;
    }
}

export const fileUtils = new FileUtil();
