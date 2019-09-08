. "C:\Users\tomoki\Git\TimeManeger\functions.ps1"

$Watch = New-Object System.Diagnostics.Stopwatch

$TARGET_PROCESS_SET_String = Read_ini AppName
$TARGET_PROCESS_SET = $TARGET_PROCESS_SET_String.Split(",")

#�j�����Ƃ̎��Ԃ̓ǂݍ���
$WhatDayToday = [String](Get-Date).DayOfWeek 
$ConfigStyle = "Time_"+([String]$WhatDayToday ).Substring(0,3)
$LockTimeMin = Read_ini $ConfigStyle
$LockTimeSec = $LockTimeMin*60

$PreAppState = 0

$OnlyOne3min = 0
$OnlyOne10sec = 0


While (1) {
	#�������ԂɂȂ��Ă��Ȃ��Ƃ�
	If ( $Watch.Elapsed.TotalSeconds -lt $LockTimeSec){
		#�A�v���̏�Ԃ̊m�F
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
		#�N����
		If ($AppState -eq 1 -and $PreAppState -eq 0){
			#�X�g�b�v�E�H�b�`���n�߂�
			Balloon "�v�����J�n"�@"Info"
			Write-Host "start"
			$Watch.Start()
		}
		#�I����
		elseif ($AppState -eq 0 -and $PreAppState -eq 1){
			#�X�g�b�v�E�H�b�`���~
			Write-Host "stop"
			$Watch.Stop()
		}
		#�N����
		elseif($AppState -eq 1 -and $PreAppState -eq 1){
			Write-Host "running"
		}
		#������
		else{
		Write-Host "standby"
		}
		#3���O�ɂȂ�����
		If ((($LockTimeSec - $Watch.Elapsed.TotalSeconds) -lt 180 ) -and ($OnlyOne3min -eq 0)){
		Balloon "�c��R���ł�" "Warning"
		$OnlyOne3min = 1
		}
		If ((($LockTimeSec - $Watch.Elapsed.TotalSeconds) -lt 10) -and ($OnlyOne10sec -eq 0)){
			Balloon "�c��10�b�ł��B�I�����Ă��������I�����Ȃ���΋����I�����܂��B" "Warning"
			$OnlyOne10sec = 1
			}
	}
	#�������Ԃ��߂����Ƃ�
	Else{
		Write-Host "end"
		Foreach ($TARGET_PROCESS In $TARGET_PROCESS_SET){
			$ErrorActionPreference = "silentlycontinue"
			$pro = Get-process $TARGET_PROCESS
			$ErrorActionPreference = "continue"
			if ( $null -ne $pro ) {
			Stop-process -name $TARGET_PROCESS
			Balloon "���Ԑ؂�ł�" "Info"
			}
		}
	}
	$PreAppState = $AppState
	Start-Sleep 1
}