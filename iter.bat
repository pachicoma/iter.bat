@echo off
setlocal enabledelayedexpansion
::#======================================================================
::# �T�@�v�F ��Q�����ȍ~�̊e�t�@�C���ɑ΂��đ�P�����̃R�}���h�����s����
::# �����P�F ���s�R�}���h�p�X
::# �����Q�F ��Q�����ȍ~�ɂ͏����Ώۃt�@�C���̃t���p�X���w�肷��
::# �����R�F ��R�����ȍ~�͉��L�I�v�V�������w��ł���
::#   /f ��Q�����̃t�@�C���̊e�s�������Ƃ��đ�P�����̃R�}���h�����s����
::#   /h �w���v�\��
::#   /i �e�t�@�C���ɑ΂��ď��������s����Θb�I�Ɋm�F���Ȃ�����s����
::#   /n �e�t�@�C���ɑ΂��đ��ݗL�����`�F�b�N���Ȃ�
::#   /r ��Q�����̃t�@�C��������f�B���N�g���ȉ����ċA�I�Ɍ�������
::#======================================================================
::#-------------------------------------------------
:: �O����
::#-------------------------------------------------
::# ���s�R�}���h�̎w��
::#-----------------------------
if "%~1"=="" (
  echo �������w�肵�ĉ�����
  call :PrintHelp
  pause
  goto ExitProc
)
set ExecCmd=%~1
::echo %ExecCmd%

::# �����I�v�V�������
::#-----------------------------
:: ���[�v�f�[�^�쐬�R�}���h(�f�t�H���g��`dir /b`)
:: �f�t�H���g��dir /b
::   /b �p�X���̂�1�s���o��
::   /s �����ΏۂɃT�u�f�B���N�g�����w��
set IterCmd=dir /b
set RequireConfirm=
set NoCheckFileExist=
for %%a in (%*) do (
  set arg=%%~a
  :: �ꕶ���ڂ�"/"�̏ꍇ�̓I�v�V�����ƌ��Ȃ�
  if "!arg:~0,1!"=="/" (
    set opt=!arg:~1,1!
    if "!opt!"=="f" (
      :: /f: �w��t�@�C���̊e�s�ɑ΂��ăR�}���h�����s����
      set IterCmd=type
    ) else if "!opt!"=="i" (
      :: /i: ���[�U�Ɋe�Ώۂ��ƂɎ��s���邩�m�F����
      set RequireConfirm=1
    ) else if "!opt!"=="n" (
      :: /n: �t�@�C���̑��݃`�F�b�N�����Ȃ�
      set NoCheckFileExist=1
    ) else if "!opt!"=="r" (
      :: /r: �T�u�f�B���N�g�����Ώ�
      set IterCmd=%IterCmd% /s
    ) else if "!opt!"=="h" (
      call :PrintHelp
      :: /?: �w���v��\��
      pause
      goto :ExitProc
    )
  )
)
::echo "%IterCmd%"
::echo "%RequireConfirm%"

:: ��ƃf�B���N�g���ړ�
::#-----------------------------
pushd "%~dp2"

::#-------------------------------------------------
::# ���C�����[�v (�����̐�����)
::#-------------------------------------------------
:StartMainLoop
  set arg=%~2
  :: �������Ȃ��Ȃ�����I��
  if "%arg%"=="" goto ExitMainLoop

  :: �I�v�V���������̏ꍇ�̓X�L�b�v
  if "%arg:~0,1%"=="/" goto NextMainLoop

  ::# ���C������
  ::#-----------------------------
  rem echo %IterCmd% %arg%
  for /f "usebackq" %%L in ( `%IterCmd% %arg%` ) do (
    rem echo Target: %%L

    ::# �t�@�C�����݃`�F�b�N
    if "%NoCheckFileExist%"=="" (
      rem �����̃t�@�C�������݂��邩�`�F�b�N
      call :DoesFileExist %%L
      set fileNotExist=!errorlevel!
    ) else (
      rem �����̃t�@�C�������݂��邩�`�F�b�N���Ȃ�
      set fileNotExist=0
    )

    ::# ���[�U�ւ̎��s�m�F
    set /a cancelRequest=0
    if not "%RequireConfirm%"=="" (
      call :ExecConfirm %%L
      set cancelRequest=!errorlevel!
    )

    ::# �e�^�[�Q�b�g�ɑ΂��ăR�}���h�����s����
    if !cancelRequest! EQU 0 (
      if !fileNotExist! EQU 0 (
        rem echo %%~fL
        rem �e�t�@�C���ɑ΂��čs������
        %ExecCmd% %%~fL
      ) else (
        rem �t�@�C�������݂��Ȃ��ꍇ
        rem echo NotFound: %%~L
      )
    )
  )

:NextMainLoop
  :: ���̃��[�v��
  shift
  goto StartMainLoop

:ExitMainLoop

::#-------------------------------------------------
::# �I������
::#-------------------------------------------------
:ExitProc
endlocal
exit /b 0


::#-------------------------------------------------
::# �T�u�֐�
::#-------------------------------------------------
::#-------------------------------------------------
::# �w���v��\������
::#-------------------------------------------------
:PrintHelp
echo.
echo  %~nx0 ���s�R�}���h �Ώۃt�@�C�� [/f /h /i /n /r]
echo.
echo    /f ��Q�����̃t�@�C���̊e�s�������Ƃ��đ�P�����̃R�}���h�����s����
echo    /h ���̃w���v��\��
echo    /i �e�t�@�C���ɑ΂��ď��������s����Θb�I�Ɋm�F���Ȃ�����s����
echo    /n �e�t�@�C���ɑ΂��đ��ݗL�����`�F�b�N���Ȃ�
echo    /r ��Q�����̃t�@�C��������f�B���N�g���ȉ����ċA�I�Ɍ�������
echo.
exit /b 0

::#-------------------------------------------------
::# �o�b�`���������s���邩���[�U�Ɋm�F����
::# �����P�F �^�[�Q�b�g
::# �߂�l�F 0: ���s����
::#          1: ���s���Ȃ�
::#-------------------------------------------------
:ExecConfirm
echo.
echo #-------------------------------------------------
echo # �Ώ�: %~1
set userKey=
set /p userKey=^> ���s���܂����H(y or n + Enter):
if not '%userKey%'=='' (
  set userKey=%userKey:~0,1%
)
:: �߂�l�X�e�[�^�X
set cancelStatus=1
if '%userKey%'=='y' (
  rem ���s����
  set cancelStatus=0
) else if '%userKey%'=='Y' (
  rem ���s����
  set cancelStatus=0
)
exit /b %cancelStatus%

::#-------------------------------------------------
::# �t�@�C�������݂��邩�`�F�b�N����
::# �����P�F �t�@�C���p�X
::# �߂�l�F 0: �t�@�C�������݂���
::#          1: �f�B���N�g�������݂���
::#          2: �t�@�C�������݂��Ȃ�
::#-------------------------------------------------
:DoesFileExist
:: �߂�l�X�e�[�^�X
set existStatus=2
if exist "%~1\*" (
  rem �f�B���N�g�������݂���
  set /a existStatus=1
) else if exist "%~1" (
  rem �t�@�C�������݂���
  set /a existStatus=0
)
exit /b %existStatus%

