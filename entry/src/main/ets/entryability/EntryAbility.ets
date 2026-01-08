/*
 * Copyright (C) 2023 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import UIAbility from '@ohos.app.ability.UIAbility';
import hilog from '@ohos.hilog';
import window from '@ohos.window';
import { GlobalContext } from '../bean/GlobalContext';
import { Permissions } from '@ohos.abilityAccessCtrl';
import AbilityConstant from '@ohos.app.ability.AbilityConstant';

import Want from '@ohos.app.ability.Want';
import abilityAccessCtrl, { Context, PermissionRequestResult } from '@ohos.abilityAccessCtrl';
import { BusinessError } from '@ohos.base';
import common from '@ohos.app.ability.common';

import featureAbility from '@ohos.ability.featureAbility';
import { bundleManager } from '@kit.AbilityKit';

const PERMISSIONS: Array<Permissions> = ['ohos.permission.READ_MEDIA', "ohos.permission.MICROPHONE", "ohos.permission.APP_TRACKING_CONSENT"];




export default class EntryAbility extends UIAbility {
    onCreate(want: Want, launchParam: AbilityConstant.LaunchParam) {
        let atManager: abilityAccessCtrl.AtManager = abilityAccessCtrl.createAtManager();
        try {
           // let context: Context = getContext(this) as common.UIAbilityContext;
            atManager.requestPermissionsFromUser(this.context, PERMISSIONS).then((data: PermissionRequestResult) => {
                console.info('data:' + JSON.stringify(data));
                console.info('data permissions:' + data.permissions);
                console.info('data authResults:' + data.authResults);
            }).catch((err: BusinessError) => {
                console.info('data:' + JSON.stringify(err));
            })
        } catch(err) {
            console.log(`catch err->${JSON.stringify(err)}`);
        }



    }




    onDestroy() {
        hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onDestroy');
    }

    onWindowStageCreate(windowStage: window.WindowStage) {
        // Main window is created, set main page for this ability
        hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onWindowStageCreate');
        GlobalContext.getContext().setObject("filesDir", this.context.filesDir);
        GlobalContext.getContext().setObject("cacheDir", this.context.cacheDir);
        GlobalContext.getContext().setObject("context", this.context);
        windowStage.loadContent('pages/PageMain', (err, data) => {
            if (err.code) {
                hilog.error(0x0000, 'testTag', 'Failed to load the content. Cause: %{public}s', JSON.stringify(err) ?? '');
                return;
            }
            hilog.info(0x0000, 'testTag', 'Succeeded in loading the content. Data: %{public}s', JSON.stringify(data) ?? '');
        });
    }

    onWindowStageDestroy() {
        // Main window is destroyed, release UI related resources
        hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onWindowStageDestroy');
    }

    onForeground() {
        // Ability has brought to foreground
        hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onForeground');
    }

    onBackground() {
        // Ability has back to background
        hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onBackground');
    }
}
