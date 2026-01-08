import {
  LogUtil,
  SpeechEventListener,
  SpeechEventManager,
  StartParamsAsr,
  SpeechAsrState,
  SpeechAsrType,
  RecordCallbackInfo,

} from '@bdbase/speech-asr';

import { common } from '@kit.AbilityKit';
import { JSON } from '@kit.ArkTS';


class AsrListener implements SpeechEventListener {
  private viewRoot: PageMain

  constructor(view: PageMain) {
    this.viewRoot = view;
  }

  onEvent(state: string, params: string, data: ArrayBuffer): void {
    // this.viewRoot.texttt = (state + ", === " + params)
  }
}


interface volumeCallbackParam {
  volume: number;
  volumePercent: number;
}

interface Result {
  word: string[];
  confident: number[];
}

// interface SaveResult {
//     result: '',
//     path: ''
// }

interface RecognizeOriginParams {
  err_no: number;
  err_msg: string;
  result: Result;
  asr_align_begin: number;
  asr_align_end: number;
  raf: number;
  early_return_duration_frame: number;
  corpus_no: number;
  sn: string;
  force_align_result: string;
  confidence_status: number;
  product_id: number;
  product_line: string;
  other_params: string;
  result_type: string;
  speak_speed: number;
  voice_power: number;
}

interface RecognizeParams {
  err_no: number;
  err_msg: string;
  best_result: string;
  sn: string;
  origin_result: RecognizeOriginParams
}

@Entry
@Component
struct PageMain {
  private context = getContext(this) as common.UIAbilityContext;
  // context: Context = GlobalContext.getContext().getObject("context") as Context
  scroller: Scroller = new Scroller()
  asrListener: AsrListener = new AsrListener(this)
  private arr: number[] = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]
  @State textResult: string = ''
  @State textLog: string = ''

  build() {
    Column() {
      Scroll(this.scroller) {
        Column() {
          Text(this.textResult)
            .fontSize(20)
            .backgroundColor(0xddeeff)
            .width('100%')
            .padding(5)
            .gesture(GestureGroup(GestureMode.Sequence, LongPressGesture({
              repeat: true,
              duration: 50
            }).onAction((_event?: GestureEvent) => {
              this.textLog = ""
            })))
          Text(this.textLog)
            .fontSize(12)
            .padding(5)
            .backgroundColor(0xffeecc)
            .width('100%')
            .height('100%')
            .textAlign(TextAlign.Start)
        }
      }
      .layoutWeight(1)
      .scrollable(ScrollDirection.Vertical) // 滚动方向纵向
      .scrollBar(BarState.On) // 滚动条常驻显示
      .scrollBarWidth(10) // 滚动条宽度
      .friction(0.6)
      .edgeEffect(EdgeEffect.None)
      .onScroll((xOffset: number, yOffset: number) => {
        console.info(xOffset + ' ' + yOffset)
      })
      .onScrollEdge((side: Edge) => {
        console.info('To the edge')
      })
      .onScrollStop(() => {
        console.info('Scroll Stop')
      })


      Row() {
        Button('startAsr', { type: ButtonType.Normal, stateEffect: true })
          .type(ButtonType.Capsule)
          .fontSize(16)
          .layoutWeight(1)
          .backgroundColor("#0x317AE7")
          .height(45)
          .onClick(() => {
            this.startAsr(SpeechAsrType.SHORT)
          })

        Button('multiAsr', { type: ButtonType.Normal, stateEffect: true })
          .type(ButtonType.Capsule)
          .fontSize(16)
          .layoutWeight(1)
          .backgroundColor("#0x317AE7")
          .height(45)
          .margin({ left: 5 })
          .onClick(() => {
            this.startAsr(SpeechAsrType.TRANSLITERATE)
          })

        Button('touchAsr', { type: ButtonType.Normal, stateEffect: true })
          .type(ButtonType.Capsule)
          .fontSize(16)
          .layoutWeight(1)
          .backgroundColor("#0x317AE7")
          .height(45)
          .margin({ left: 5 })
          .onTouch(async (event?: TouchEvent) => {
            if (event) {
              if (event.type === TouchType.Down) {
                console.info("ui------------------touch down")
                this.startAsr(SpeechAsrType.TOUCH)
              } else if (event.type === TouchType.Up) {
                console.info("ui------------------touch up")
                SpeechEventManager.getInstance().stopAsr()
              }
            }
          })
      }.padding(5)

      Row() {
        Button('cancelAsr', { type: ButtonType.Normal, stateEffect: true })
          .type(ButtonType.Capsule)
          .layoutWeight(1)
          .fontSize(16)
          .backgroundColor("#0x317AE7")
          .height(45)
          .onClick(async () => {
            SpeechEventManager.getInstance().cancelAsr()
          })

        Button('stopAsr', { type: ButtonType.Normal, stateEffect: true })
          .type(ButtonType.Capsule)
          .layoutWeight(1)
          .fontSize(16)
          .backgroundColor("#0x317AE7")
          .height(45)
          .margin({ left: 5 })
          .onClick(async () => {
            SpeechEventManager.getInstance().stopAsr()
          })

      }.padding(5)
    }.width('100%').height('100%').backgroundColor(0xDCDCDC)
  }

  aboutToAppear() {
    SpeechEventManager.getInstance().initSdk(this.context, "", "")
  }

  async startAsr(asrType: number) {
    LogUtil.isLog = true; // 打开日志
    let startParams: StartParamsAsr = new StartParamsAsr()
    startParams.earlyReturn = 1
    startParams.asrType = asrType
    startParams.authInfo = { ak: "your ak", sk: "your sk" }

    SpeechEventManager.getInstance().startAsr(startParams, this.asrListener,
      (asrState: string, params: string = '', audioData: ArrayBuffer) => {
        let showMsg = "----" + asrState + ", " + params
        let msg = "Asr callback: " + showMsg
        LogUtil.d(msg)

        if (asrState === SpeechAsrState.ASR_AUDIO_DATA) {
        } else if (asrState === SpeechAsrState.ASR_AUDIO_INFO) {
          let obj = JSON.parse(params) as RecordCallbackInfo
          console.info(`ASR_AUDIO_INFO index:${obj.index} source:${obj.source}`)
        } else if (asrState === SpeechAsrState.ASR_AUDIO_VOLUME_LEVEL) {
          let obj = JSON.parse(params) as volumeCallbackParam;
          let volume: number = obj?.volume;
          let volumePercent: number = obj?.volumePercent
          console.info(`ASR_AUDIO_VOLUME_LEVEL volume:${volume} volumePercent:${volumePercent}`)
        } else if (asrState === SpeechAsrState.ASR_START || asrState === SpeechAsrState.ASR_READY ||
          asrState === SpeechAsrState.ASR_BEGIN || asrState === SpeechAsrState.ASR_END ||
          asrState === SpeechAsrState.ASR_EXIT ||
          asrState === SpeechAsrState.ASR_CANCEL || asrState === SpeechAsrState.ASR_STOP) {
          this.appendLog(showMsg)
        } else if (asrState === SpeechAsrState.ASR_PARTIAL) { // 中间结果
          const parsedResponse = JSON.parse(params) as RecognizeParams
          let partialResult = parsedResponse?.best_result
          let logMsg = "Partial result: " + partialResult
          console.log(logMsg)
          this.textResult = logMsg
        } else if (asrState === SpeechAsrState.ASR_TTS) { // tts
        } else if (asrState === SpeechAsrState.ASR_THIRD) { // 三方数据
        } else if (asrState === SpeechAsrState.ASR_FINAL) { // 最终结果
          const parsedResponse = JSON.parse(params) as RecognizeParams
          let logMsg = ''
          if (parsedResponse.err_no != 0) {
            logMsg = "Final result: " + parsedResponse?.err_no + " " + parsedResponse?.err_msg
          } else {
            logMsg = "Final result: " + parsedResponse?.best_result
          }
          console.log(logMsg)
          this.textResult = logMsg
        } else if (asrState === SpeechAsrState.ASR_FINISH) { // 识别结束
          this.appendLog(showMsg)
        }

        if (asrState === SpeechAsrState.ASR_EXIT) {

        }
      })
  }

  appendLog(msg: string) {
    this.textLog = msg + '\n' + this.textLog
  }
}
