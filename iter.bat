@echo off
setlocal enabledelayedexpansion
::#======================================================================
::# 概　要： 第２引数以降の各ファイルに対して第１引数のコマンドを実行する
::# 引数１： 実行コマンドパス
::# 引数２： 第２引数以降には処理対象ファイルのフルパスを指定する
::# 引数３： 第３引数以降は下記オプションを指定できる
::#   /f 第２引数のファイルの各行を引数として第１引数のコマンドを実行する
::#   /h ヘルプ表示
::#   /i 各ファイルに対して処理を実行する対話的に確認しながら実行する
::#   /n 各ファイルに対して存在有無をチェックしない
::#   /r 第２引数のファイルがあるディレクトリ以下を再帰的に検索する
::#======================================================================
::#-------------------------------------------------
:: 前処理
::#-------------------------------------------------
::# 実行コマンドの指定
::#-----------------------------
if "%~1"=="" (
  echo 引数を指定して下さい
  call :PrintHelp
  pause
  goto ExitProc
)
set ExecCmd=%~1
::echo %ExecCmd%

::# 引数オプション解析
::#-----------------------------
:: ループデータ作成コマンド(デフォルトは`dir /b`)
:: デフォルトはdir /b
::   /b パス情報のみ1行ずつ出力
::   /s 検索対象にサブディレクトリを指定
set IterCmd=dir /b
set RequireConfirm=
set NoCheckFileExist=
for %%a in (%*) do (
  set arg=%%~a
  :: 一文字目が"/"の場合はオプションと見なす
  if "!arg:~0,1!"=="/" (
    set opt=!arg:~1,1!
    if "!opt!"=="f" (
      :: /f: 指定ファイルの各行に対してコマンドを実行する
      set IterCmd=type
    ) else if "!opt!"=="i" (
      :: /i: ユーザに各対象ごとに実行するか確認する
      set RequireConfirm=1
    ) else if "!opt!"=="n" (
      :: /n: ファイルの存在チェックをしない
      set NoCheckFileExist=1
    ) else if "!opt!"=="r" (
      :: /r: サブディレクトリも対象
      set IterCmd=%IterCmd% /s
    ) else if "!opt!"=="h" (
      call :PrintHelp
      :: /?: ヘルプを表示
      pause
      goto :ExitProc
    )
  )
)
::echo "%IterCmd%"
::echo "%RequireConfirm%"

:: 作業ディレクトリ移動
::#-----------------------------
pushd "%~dp2"

::#-------------------------------------------------
::# メインループ (引数の数だけ)
::#-------------------------------------------------
:StartMainLoop
  set arg=%~2
  :: 引数がなくなったら終了
  if "%arg%"=="" goto ExitMainLoop

  :: オプション引数の場合はスキップ
  if "%arg:~0,1%"=="/" goto NextMainLoop

  ::# メイン処理
  ::#-----------------------------
  rem echo %IterCmd% %arg%
  for /f "usebackq" %%L in ( `%IterCmd% %arg%` ) do (
    rem echo Target: %%L

    ::# ファイル存在チェック
    if "%NoCheckFileExist%"=="" (
      rem 引数のファイルが存在するかチェック
      call :DoesFileExist %%L
      set fileNotExist=!errorlevel!
    ) else (
      rem 引数のファイルが存在するかチェックしない
      set fileNotExist=0
    )

    ::# ユーザへの実行確認
    set /a cancelRequest=0
    if not "%RequireConfirm%"=="" (
      call :ExecConfirm %%L
      set cancelRequest=!errorlevel!
    )

    ::# 各ターゲットに対してコマンドを実行する
    if !cancelRequest! EQU 0 (
      if !fileNotExist! EQU 0 (
        rem echo %%~fL
        rem 各ファイルに対して行う処理
        %ExecCmd% %%~fL
      ) else (
        rem ファイルが存在しない場合
        rem echo NotFound: %%~L
      )
    )
  )

:NextMainLoop
  :: 次のループへ
  shift
  goto StartMainLoop

:ExitMainLoop

::#-------------------------------------------------
::# 終了処理
::#-------------------------------------------------
:ExitProc
endlocal
exit /b 0


::#-------------------------------------------------
::# サブ関数
::#-------------------------------------------------
::#-------------------------------------------------
::# ヘルプを表示する
::#-------------------------------------------------
:PrintHelp
echo.
echo  %~nx0 実行コマンド 対象ファイル [/f /h /i /n /r]
echo.
echo    /f 第２引数のファイルの各行を引数として第１引数のコマンドを実行する
echo    /h このヘルプを表示
echo    /i 各ファイルに対して処理を実行する対話的に確認しながら実行する
echo    /n 各ファイルに対して存在有無をチェックしない
echo    /r 第２引数のファイルがあるディレクトリ以下を再帰的に検索する
echo.
exit /b 0

::#-------------------------------------------------
::# バッチ処理を実行するかユーザに確認する
::# 引数１： ターゲット
::# 戻り値： 0: 実行する
::#          1: 実行しない
::#-------------------------------------------------
:ExecConfirm
echo.
echo #-------------------------------------------------
echo # 対象: %~1
set userKey=
set /p userKey=^> 実行しますか？(y or n + Enter):
if not '%userKey%'=='' (
  set userKey=%userKey:~0,1%
)
:: 戻り値ステータス
set cancelStatus=1
if '%userKey%'=='y' (
  rem 実行する
  set cancelStatus=0
) else if '%userKey%'=='Y' (
  rem 実行する
  set cancelStatus=0
)
exit /b %cancelStatus%

::#-------------------------------------------------
::# ファイルが存在するかチェックする
::# 引数１： ファイルパス
::# 戻り値： 0: ファイルが存在する
::#          1: ディレクトリが存在する
::#          2: ファイルが存在しない
::#-------------------------------------------------
:DoesFileExist
:: 戻り値ステータス
set existStatus=2
if exist "%~1\*" (
  rem ディレクトリが存在する
  set /a existStatus=1
) else if exist "%~1" (
  rem ファイルが存在する
  set /a existStatus=0
)
exit /b %existStatus%

