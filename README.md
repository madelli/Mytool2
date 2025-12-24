web application 作成中。

★フォルダ構成
C:\Mytool_ver2\
│
├─ start_app.cmd          ← ★ アプリ起動用（ダブルクリックで起動）
├─ server.ps1             ← ★ GUI + API 統合サーバー（ポート8001など）
│
├─ public\                ← ★ GUI（ブラウザ画面）
│   ├─ index.html
│   ├─ style.css
│   └─ app.js
│
└─ logs\                  ← ★ ログ保存フォルダ
    └─ server.log

各フォルダ・ファイルの役割
〇start_app.cmd 
• 	ダブルクリックでアプリを起動
• 	ブラウザを自動で開く
• 	server.ps1 を起動する
〇server.ps1 
• 	PowerShell で動くローカルサーバー
• 	GUI（HTML）を配信
• 	API（sysinfo / open_excel / open_folder）を処理
• 	ログを記録
〇public\ 
• 	index.html（画面）
• 	style.css（デザイン）
• 	app.js（ボタン → API 呼び出し）
〇logs\ 
• 	server.log（アクセス・エラー記録）
