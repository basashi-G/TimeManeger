#バルーン
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
	#5000ミリ秒表示
	$balloon.ShowBalloonTip(5000)
	#1秒待ってからタスクトレイアイコン非表示
	Start-Sleep -Seconds 10
	$balloon.Visible = $False
}

#configの読み込み
Function Read_ini ($item){
	$Lines = get-content .\config.ini
	foreach($line in $lines){
		# コメントと空行を除外する
		if($line -match "^$"){ continue }
		if($line -match "^\s*;"){ continue }

		$param = $line.split("=",2)
		if($param[0] -eq $item){
			return $param[1]
		}
	}
}
