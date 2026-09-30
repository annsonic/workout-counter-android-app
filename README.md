# workout-counter-app
給教練用的雙人輪替計時器 APP

[UI demo 網頁](https://annsonic.github.io/workout-counter/)，請用 Chrome 開啟網頁，才能確保 Google 小姐可以正常發音。

### 特色
1. 適用於兩人一組輪流操作器材
2. 中文口令(使用 Web Speech API 發音)
3. 支援訓練中途修改計時條件

### 操作步驟
1. 設定參數 (setup-screen)
   使用者輸入三個訓練參數：

   - 動作項目 (Rounds)：要執行幾個不同動作
   - 單人循環 (Sets)：每個動作要做幾遍
   - 運動時間 (秒)：每次運動持續秒數

2. 點擊「開始訓練」

- 進度條
  ```
  動作1 [████░░░░] 動作2 [░░░░░░░░] ... 動作5 [░░░░░░░░]
  ```
  進度條按照動作數量切大段
- 時間資訊
  - 背景色：預備時 🟠 #7a5c4a 棕色、運動時 🟢 #4a6b5a 苔綠色
  - 大型數字顯示：1-1 (第幾遍動作-學員編號)
  - 倒數時間：兩位數字，等寬字體固定寬度
  - 階段標籤：「預備 PREP」或「運動 WORK」
  - 準備時間
    - 學員已就位，教練按下開始鍵後，給予 8 秒的準備時間
    - 同個器材（動作）內換人，給予 20 秒的準備時間
    - 換器材（換動作）給予 25 秒的準備時間
- 口令順序
  - 一之一預備
  - 3, 2, 1秒
  - 開始
  - 3, 2, 1秒
  - 換人
  - 3, 2, 1秒
  - 訓練結束
- 其他按鈕
  - 暫停/繼續：暫停倒數，同時取消語音播報
  - 退出重來：回到設定畫面 
  - 調整參數：限制在「預備」期間才允許操作
    - 方便教練在訓練已經開始一段時間後，因應學生狀態而增減動作項目、增減重複次數或是增減一個動作的時間長度

<details>

<summary>開發 Android APP</summary>

#### 1️⃣ 安裝 Flutter

##### 1.1 下載 Flutter SDK

[官方安裝教學](https://docs.flutter.dev/install/quick)

- 記得把 Flutter SDK 路徑加到環境變數 $PATH 裡 

##### 1.2 執行 Flutter doctor 檢查必要套件

終端機指令

```
$ flutter doctor
```

#### 2️⃣ 安裝 Android Studio

##### 2.1 下載並安裝
[官方安裝教學](https://developer.android.com/studio/install?hl=zh-tw)

##### 2.1.1（Ubuntu 使用者）啟動 Android Studio

若是在 Ubuntu 上手動安裝（解壓縮版），需透過終端機啟動：

```
$ cd ~/android-studio/bin
$ ./studio.sh
```

首次啟動後，可在 Android Studio 內選擇 `Tools` > `Create Desktop Entry...` 建立桌面捷徑，之後即可直接點擊圖示開啟。

##### 2.2 完成初始設置

- 首次啟動 Android Studio 時，選擇「Do not import settings」
- 選擇「Standard」安裝類型
- 同意許可協議
- 讓它下載並安裝 SDK（這需要 10-20 分鐘）


#### 3️⃣ 安裝並設定 Android Emulator

##### 3.1 開啟 Virtual Device Manager

- 開啟 Android Studio，點選右上角工具列的「Device Manager」（或從選單 `Tools` > `Device Manager` 進入）

##### 3.2 建立虛擬裝置 (Create Virtual Device)

- 點選「Create Virtual Device」
- 選擇一款手機型號（例如 Pixel 6），點擊「Next」
- 選擇系統映像檔 (System Image)，建議選擇最新的 Android 版本（若尚未下載，點旁邊的「Download」下載）
- 點擊「Next」→「Finish」完成建立

##### 3.3 啟動模擬器

- 在 Device Manager 列表中，點選裝置旁的「▶」執行按鈕啟動模擬器
- 等待模擬器完全開機後即可使用

#### 4️⃣ 安裝 Flutter 的 Android 套件

##### 4.1 同意 Android 授權條款

終端機指令

```
$ flutter doctor --android-licenses
```

- 依序輸入 `y` 同意所有授權條款

##### 4.2 再次執行 flutter doctor 確認環境完整

終端機指令

```
$ flutter doctor -v
```

- 確認 `Android toolchain`、`Android Studio` 項目前面都顯示綠色打勾 ✅
- 若有缺少的套件，依照提示訊息安裝

#### 5️⃣ 編譯程式

##### 5.1 取得專案相依套件

在專案根目錄下執行

```
$ flutter pub get
```

##### 5.2 確認已連接的裝置（模擬器或實體手機）

```
$ flutter devices
```

##### 5.3 執行 / 偵錯模式（在模擬器或已連接手機上即時預覽）

```
$ flutter run
```

##### 5.4 編譯正式版 APK

```
$ flutter build apk --release
```

- 編譯完成後，APK 檔案會產生在專案目錄下的：
  `build/app/outputs/flutter-apk/app-release.apk`

##### VSCode Dart & Flutter 官方擴充套件

可以透過「指令面板」（Ctrl+Shift+P）以圖形化方式取代終端機指令：

| 終端機指令 | VSCode 指令面板對應 |
| ------ | ------ |
| flutter doctor / flutter doctor --android-licenses | Flutter: Run Flutter Doctor（授權條款仍需用終端機 --android-licenses，因為要互動輸入 y） |
| flutter pub get | Flutter: Get Packages |
| flutter run | 按 F5 或點左側「執行與偵錯」按鈕，或 Flutter: Run Flutter Application |
| flutter build apk --release | Flutter: Build APK（若要指定 --release 需在終端機或於指令後加參數，圖形化選項通常預設為 release）|
| flutter devices | 底部狀態列會直接顯示已連接裝置，可點選切換 |

#### 6️⃣ 安裝 APK 到手機

##### 6.1 開啟手機的「未知來源安裝」權限

- 手機設定 > 安全性 > 允許安裝未知來源應用程式（不同手機廠牌選單名稱可能略有差異）

##### 6.2 使用 USB 連接手機並透過 adb 安裝

終端機指令

```
$ adb install build/app/outputs/flutter-apk/app-release.apk
```

##### 6.3 或直接傳送 APK 檔案到手機

- 將 `app-release.apk` 檔案透過 email、雲端硬碟或傳輸線複製到手機
- 在手機上開啟該檔案，依照畫面指示完成安裝

</details>

<details>

<summary>開發 iOS APP</summary>

⚠️ 注意：編譯與安裝 iOS APP **必須使用 macOS 電腦**（Xcode 僅支援 macOS），Windows/Linux 無法完成此流程。

⚠️ 注意：以下教學步驟為 AI 生成，本人因為無 macOS 電腦，所以沒有驗證過以下的步驟。

#### 1️⃣ 安裝 Flutter（若已於 Android 教學安裝過可跳過）

##### 1.1 下載 Flutter SDK

[官方安裝教學](https://docs.flutter.dev/install/quick)

- 記得把 Flutter SDK 路徑加到環境變數 `$PATH` 裡

##### 1.2 執行 Flutter doctor 檢查必要套件

終端機指令

```
$ flutter doctor
```

#### 2️⃣ 安裝 Xcode

##### 2.1 從 App Store 下載並安裝 Xcode

- 開啟 Mac 上的 App Store，搜尋「Xcode」並安裝（檔案較大，需視網路狀況等待數十分鐘）

##### 2.2 安裝 Command Line Tools

終端機指令

```
$ sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer
$ sudo xcodebuild -runFirstLaunch
```

##### 2.3 同意授權條款

終端機指令

```
$ sudo xcodebuild -license
```

- 依畫面指示閱讀並輸入 `agree` 同意條款

##### 2.4 確認 Flutter 偵測到 Xcode

終端機指令

```
$ flutter doctor -v
```

- 確認 `Xcode - develop for iOS and macOS` 項目前面顯示綠色打勾 ✅

#### 3️⃣ 安裝並設定 iOS Simulator

##### 3.1 開啟模擬器

終端機指令

```
$ open -a Simulator
```

- 或從 Xcode 選單 `Xcode` > `Open Developer Tool` > `Simulator` 開啟

##### 3.2 選擇模擬機型

- 在模擬器視窗選單 `File` > `Open Simulator`，選擇欲測試的 iPhone 機型（若尚未下載該機型的系統映像檔，需先透過 Xcode 的 `Settings` > `Platforms` 下載）

#### 4️⃣ 安裝 CocoaPods（管理 iOS 相依套件）

終端機指令

```
$ sudo gem install cocoapods
```

- 若使用 Homebrew，也可改用：

```
$ brew install cocoapods
```

#### 5️⃣ 編譯程式

##### 5.1 取得專案相依套件

在專案根目錄下執行

```
$ flutter pub get
```

##### 5.2 確認已連接的裝置（模擬器或實體 iPhone）

```
$ flutter devices
```

##### 5.3 執行 / 偵錯模式（在模擬器或已連接 iPhone 上即時預覽）

```
$ flutter run
```

##### 5.4 編譯正式版 IPA（安裝檔）

終端機指令

```
$ flutter build ipa --release
```

- 編譯完成後，IPA 檔案會產生在專案目錄下的：
  `build/ios/ipa/`

⚠️ 若要將 APP 安裝到**實體 iPhone**（非模擬器），需要：
- 一組 Apple ID（免費即可用於個人測試，但憑證每 7 天需重新簽署）
- 或付費的 Apple Developer 帳號（年費 US$99，可長期簽署、上架 App Store）

#### 6️⃣ 安裝 APP 到實體 iPhone

##### 6.1 使用 Xcode 設定簽署 (Signing)

- 在專案目錄下開啟 `ios/Runner.xcworkspace`（**注意是 `.xcworkspace` 而非 `.xcodeproj`**）
- 於 Xcode 左側選擇 `Runner` 專案 > `Signing & Capabilities`
- 勾選「Automatically manage signing」，並在 `Team` 選單登入你的 Apple ID

##### 6.2 用 USB 連接 iPhone 並信任裝置

- 首次連接時，iPhone 會跳出「是否信任這台電腦」，選擇「信任」
- 在 Mac 的「設定」>「隱私權與安全性」中，允許來自你 Apple ID 的開發者 APP

##### 6.3 透過 Flutter 直接安裝到手機

終端機指令

```
$ flutter run --release -d <裝置名稱或ID>
```

- `<裝置名稱或ID>` 可透過 `flutter devices` 指令查詢

##### 6.4 或透過 Xcode 安裝

- 在 Xcode 上方裝置選單選擇你的 iPhone
- 點擊左上角「▶」執行按鈕，將 APP 安裝並啟動到手機上

</details>