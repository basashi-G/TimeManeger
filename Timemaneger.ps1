$ErrorActionPreference = "stop"
$TARGET_PROCESS_SET = "notepad","Hacknet","MiniMetro","PapersPlease","reprisaluniverse","Epistory"
$LookTime = 10 #秒

$PreAppState = 0

$Watch = New-Object System.Diagnostics.Stopwatch
$OnlyOne = 0

Function Balloon ($Msg,$IconType) {
    #System.Windows.FormsクラスをPowerShellセッションに追加
    Add-Type -AssemblyName System.Windows.Forms
    #NotifyIconクラスをインスタンス化
    $balloon = New-Object System.Windows.Forms.NotifyIcon
    #powershellのアイコンを抜き出す
    $balloon.Icon = [System.Drawing.Icon]::ExtractAssociatedIcon('C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe')
    #特定のTipIconのみを使用可
    #[System.Windows.Forms.ToolTipIcon] | Get-Member -Static -Type Property
    $balloon.BalloonTipIcon  = [System.Windows.Forms.ToolTipIcon]::$IconType
    #表示するメッセージ
    $balloon.BalloonTipText  = $Msg
    #表示するタイトル
    $balloon.BalloonTipTitle = 'TimeManeger'
    #タスクトレイアイコン表示
    $balloon.Visible = $True
    #1000ミリ秒表示
    $balloon.ShowBalloonTip(5000)
    #1秒待ってからタスクトレイアイコン非表示
    Start-Sleep -Seconds 10
    $balloon.Visible = $False
}

While (1) {
    If ( $Watch.Elapsed.TotalSeconds -lt $LookTime){
        $AppState = 0
        Foreach ($TARGET_PROCESS In $TARGET_PROCESS_SET){
            $ErrorActionPreference = "silentlycontinue"
            $Pro = Get-process $TARGET_PROCESS_SET
            $ErrorActionPreference = "continue"
            If ( $Pro -ne $null ) {
                $AppState = 1
            }
        }
        #起動したとき
        If ($AppState -eq 1 -and $PreAppState -eq 0){
            #ストップウォッチを始める
            Balloon "計測を開始"　"Info"
            echo "start"
            $Watch.Start()
        }
        #終了時
        elseif ($AppState -eq 0 -and $PreAppState -eq 1){
            #ストップウォッチを停止
            echo "stop"
            $Watch.Stop()
        }
        elseif($AppState -eq 1 -and $PreAppState -eq 1){
            echo "running"
        }
        else{
        echo "standby"
        }

        If ((($LookTime - $Watch.Elapsed.TotalSeconds) -lt 5 ) -and ($OnlyOne -eq 0)){
        Balloon "残り３分です" "Warning"
		$OnlyOne = 1
        }
    }
    Else{
        Foreach ($TARGET_PROCESS In $TARGET_PROCESS_SET){
            $ErrorActionPreference = "silentlycontinue"
            $pro = Get-process $TARGET_PROCESS
            $ErrorActionPreference = "continue"
            if ( $pro -ne $null ) {
            Stop-process -name $TARGET_PROCESS
            Balloon "時間切れです" "Info"
            }
        }

    }
    $PreAppState = $AppState
    Start-Sleep 1
}