# ================================
# GUI + API 統合 PowerShell サーバー
# ================================

$baseDir = "C:\Mytool_ver2"
$publicDir = "$baseDir\public"
$logDir = "$baseDir\logs"
$logPath = "$logDir\server.log"
$port = 8000

# ログフォルダ作成
if (-not (Test-Path $logDir)) {
    New-Item -ItemType Directory -Path $logDir | Out-Null
}

function Log($msg) {
    $timestamp = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
    "$timestamp  $msg" | Out-File -FilePath $logPath -Append
}

# HttpListener 起動
$listener = New-Object System.Net.HttpListener
$listener.Prefixes.Add("http://localhost:$port/")
$listener.Start()

Log "Server started on http://localhost:$port/"
Write-Host "Server started → http://localhost:$port/index.html"

while ($true) {
    try {
        $context = $listener.GetContext()
        $req = $context.Request
        $res = $context.Response

        $path = $req.Url.AbsolutePath.TrimStart("/")
        Log "Request: /$path"

        # -------------------------
        # API エンドポイント
        # -------------------------
        switch ($path) {

            "sysinfo" {
                try {
                    $mem = Get-CimInstance Win32_OperatingSystem
                    $total = [math]::Round($mem.TotalVisibleMemorySize / 1MB, 2)
                    $free  = [math]::Round($mem.FreePhysicalMemory / 1MB, 2)
                    $used  = [math]::Round($total - $free, 2)

                    $net = Get-NetIPAddress | Where-Object { $_.AddressFamily -eq "IPv4" -and $_.IPAddress -notlike "169.*" }
                    $ip = $net.IPAddress
                    $mac = (Get-NetAdapter | Where-Object { $_.Status -eq "Up" }).MacAddress

                    $json = @{
                        memory = "$used GB / $total GB"
                        ip     = $ip
                        mac    = $mac
                    } | ConvertTo-Json
                }
                catch {
                    Log "ERROR sysinfo → $_"
                    $json = '{ "error": "sysinfo failed" }'
                }

                $bytes = [Text.Encoding]::UTF8.GetBytes($json)
                $res.ContentType = "application/json"
                $res.OutputStream.Write($bytes, 0, $bytes.Length)
                $res.OutputStream.Close()
                continue
            }

            "open_excel" {
                Start-Process "excel.exe"
                $json = '{ "result": "Excel opened" }'
                $bytes = [Text.Encoding]::UTF8.GetBytes($json)
                $res.ContentType = "application/json"
                $res.OutputStream.Write($bytes, 0, $bytes.Length)
                $res.OutputStream.Close()
                continue
            }

            "open_folder" {
                Start-Process $baseDir
                $json = '{ "result": "Folder opened" }'
                $bytes = [Text.Encoding]::UTF8.GetBytes($json)
                $res.ContentType = "application/json"
                $res.OutputStream.Write($bytes, 0, $bytes.Length)
                $res.OutputStream.Close()
                continue
            }
        }

        # -------------------------
        # 静的ファイル配信
        # -------------------------
        if ($path -eq "") { $path = "index.html" }

        $filePath = Join-Path $publicDir $path

        if (Test-Path $filePath) {
            $bytes = [IO.File]::ReadAllBytes($filePath)

            switch ([IO.Path]::GetExtension($filePath)) {
                ".html" { $res.ContentType = "text/html" }
                ".css"  { $res.ContentType = "text/css" }
                ".js"   { $res.ContentType = "application/javascript" }
                default { $res.ContentType = "application/octet-stream" }
            }

            $res.OutputStream.Write($bytes, 0, $bytes.Length)
        } else {
            $res.StatusCode = 404
            $err = [Text.Encoding]::UTF8.GetBytes("404 Not Found")
            $res.OutputStream.Write($err, 0, $err.Length)
        }

        $res.OutputStream.Close()
    }
    catch {
        Log "ERROR main loop → $_"
    }
}

