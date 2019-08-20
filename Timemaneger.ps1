$ErrorActionPreference = "stop"
$TARGET_PROCESS_SET = "notepad","Hacknet","MiniMetro","PapersPlease","reprisaluniverse","Epistory"
$LookTime = 10 #�b

$PreAppState = 0

$Watch = New-Object System.Diagnostics.Stopwatch
$OnlyOne = 0

Function Balloon ($Msg,$IconType) {
    #System.Windows.Forms�N���X��PowerShell�Z�b�V�����ɒǉ�
    Add-Type -AssemblyName System.Windows.Forms
    #NotifyIcon�N���X���C���X�^���X��
    $balloon = New-Object System.Windows.Forms.NotifyIcon
    #powershell�̃A�C�R���𔲂��o��
    $balloon.Icon = [System.Drawing.Icon]::ExtractAssociatedIcon('C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe')
    #�����TipIcon�݂̂��g�p��
    #[System.Windows.Forms.ToolTipIcon] | Get-Member -Static -Type Property
    $balloon.BalloonTipIcon  = [System.Windows.Forms.ToolTipIcon]::$IconType
    #�\�����郁�b�Z�[�W
    $balloon.BalloonTipText  = $Msg
    #�\������^�C�g��
    $balloon.BalloonTipTitle = 'TimeManeger'
    #�^�X�N�g���C�A�C�R���\��
    $balloon.Visible = $True
    #1000�~���b�\��
    $balloon.ShowBalloonTip(5000)
    #1�b�҂��Ă���^�X�N�g���C�A�C�R����\��
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
        #�N�������Ƃ�
        If ($AppState -eq 1 -and $PreAppState -eq 0){
            #�X�g�b�v�E�H�b�`���n�߂�
            Balloon "�v�����J�n"�@"Info"
            echo "start"
            $Watch.Start()
        }
        #�I����
        elseif ($AppState -eq 0 -and $PreAppState -eq 1){
            #�X�g�b�v�E�H�b�`���~
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
        Balloon "�c��R���ł�" "Warning"
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
            Balloon "���Ԑ؂�ł�" "Info"
            }
        }

    }
    $PreAppState = $AppState
    Start-Sleep 1
}