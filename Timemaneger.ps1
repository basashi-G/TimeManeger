. "C:\Users\tomoki\Git\TimeManeger\functions.ps1"

$Watch = New-Object System.Diagnostics.Stopwatch

$TARGET_PROCESS_SET_String = Read_ini AppName
$TARGET_PROCESS_SET = $TARGET_PROCESS_SET_String.Split(",")

#曜日ごとの時間の読み込み
$WhatDayToday = [String](Get-Date).DayOfWeek 
$ConfigStyle = "Time_"+([String]$WhatDayToday ).Substring(0,3)
$LockTimeMin = Read_ini $ConfigStyle
$LockTimeSec = $LockTimeMin*60

$PreAppState = 0

$OnlyOne3min = 0
$OnlyOne10sec = 0

#日付による初期化
$line = Get-Content .\memory
$content = $line.split(">",2)
$memorydate = $content[0]
#違う日
if([string](Get-Date -Format "yyyy/MM/dd") -ne $memorydate){
	Clear-Content .\memory
	$memorytime = 0
}
#同じ日
else {
	$memorytime = $content[1]
}


While (1) {
	$Totaltime = $Watch.Elapsed.TotalSeconds + [int]$memorytime
	#制限時間になっていないとき
	If ( $Totaltime -lt $LockTimeSec){
		#アプリの状態の確認
		Foreach ($TARGET_PROCESS In $TARGET_PROCESS_SET){
			$ErrorActionPreference = "silentlycontinue"
			$Pro = Get-process $TARGET_PROCESS
			$ErrorActionPreference = "continue"
			If ( $null -ne $Pro ) {
				$AppState = 1
				break
			}
			$AppState = 0
		}
		#起動時
		If ($AppState -eq 1 -and $PreAppState -eq 0){
			#ストップウォッチを始める
			Balloon "計測を開始"　"Info"
			Write-Host "start"
			$Watch.Start()
		}
		#終了時
		elseif ($AppState -eq 0 -and $PreAppState -eq 1){
			#ストップウォッチを停止
			Write-Host "stop"
			$Watch.Stop()
		}
		#起動中
		elseif($AppState -eq 1 -and $PreAppState -eq 1){
			Write-Host "running"
		}
		#未操作
		else{
		Write-Host "standby"
		}
		#3分前になったら
		If ((($LockTimeSec - $Totaltime) -lt 180 ) -and ($OnlyOne3min -eq 0)){
		Balloon "残り３分です" "Warning"
		$OnlyOne3min = 1
		}
		If ((($LockTimeSec - $Totaltime) -lt 10) -and ($OnlyOne10sec -eq 0)){
			Balloon "残り10秒です。終了してください！さもなければ強制終了します。" "Warning"
			$OnlyOne10sec = 1
			}
	}
	#制限時間を過ぎたとき
	Else{
		Write-Host "end"
		Foreach ($TARGET_PROCESS In $TARGET_PROCESS_SET){
			$ErrorActionPreference = "silentlycontinue"
			$pro = Get-process $TARGET_PROCESS
			$ErrorActionPreference = "continue"
			if ( $null -ne $pro ) {
			Stop-process -name $TARGET_PROCESS
			Balloon "時間切れです" "Info"
			}
		}
	}
	$PreAppState = $AppState
	$nowdate = Get-Date -Format "yyyy/MM/dd"
	Set-Content -Path .\memory -Value $nowdate">"$Totaltime 
	Start-Sleep 1
}