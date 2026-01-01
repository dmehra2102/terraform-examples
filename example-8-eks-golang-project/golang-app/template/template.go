package template

var TemplateBody = `
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>AWS Resources Dashboard</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        body {
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
            padding: 20px;
        }

        .container {
            max-width: 1200px;
            margin: 0 auto;
        }

        header {
            background: white;
            padding: 30px;
            border-radius: 10px;
            box-shadow: 0 10px 30px rgba(0,0,0,0.2);
            margin-bottom: 30px;
            text-align: center;
        }

        header h1 {
            color: #333;
            margin-bottom: 10px;
            font-size: 2.5em;
        }

        header p {
            color: #666;
            font-size: 1.1em;
        }

        .dashboard {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(350px, 1fr));
            gap: 20px;
            margin-bottom: 20px;
        }

        .card {
            background: white;
            border-radius: 10px;
            box-shadow: 0 10px 30px rgba(0,0,0,0.2);
            overflow: hidden;
        }

        .card-header {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            padding: 20px;
            font-size: 1.5em;
            font-weight: bold;
        }

        .card-header.s3 { background: linear-gradient(135deg, #FF9900 0%, #FF7300 100%); }
        .card-header.iam { background: linear-gradient(135deg, #4CAF50 0%, #45a049 100%); }
        .card-header.roles { background: linear-gradient(135deg, #2196F3 0%, #0b7dda 100%); }

        .card-body {
            padding: 20px;
            max-height: 500px;
            overflow-y: auto;
        }

        .item {
            padding: 12px;
            border-bottom: 1px solid #eee;
            font-size: 0.95em;
        }

        .item:last-child {
            border-bottom: none;
        }

        .item-name {
            font-weight: bold;
            color: #333;
            margin-bottom: 5px;
        }

        .item-details {
            color: #666;
            font-size: 0.9em;
            line-height: 1.5;
        }

        .error {
            background-color: #f8d7da;
            border: 1px solid #f5c6cb;
            color: #721c24;
            padding: 12px;
            border-radius: 4px;
            margin-bottom: 20px;
        }

        .empty {
            color: #999;
            font-style: italic;
            padding: 20px;
            text-align: center;
        }

        .badge {
            display: inline-block;
            background: #e0e0e0;
            padding: 4px 8px;
            border-radius: 4px;
            font-size: 0.8em;
            color: #333;
            margin-right: 5px;
        }

        @media (max-width: 768px) {
            header h1 {
                font-size: 1.8em;
            }

            .dashboard {
                grid-template-columns: 1fr;
            }
        }
    </style>
</head>
<body>
    <div class="container">
        <header>
            <h1>☁️ AWS Resources Dashboard</h1>
            <p>Real-time view of your S3 buckets, IAM users, and roles</p>
        </header>

        {{if .Error}}
            <div class="error">⚠️ <strong>Error:</strong> {{.Error}}</div>
        {{end}}

        <div class="dashboard">
            <div class="card">
                <div class="card-header s3">
                    🪣 S3 Buckets ({{len .S3Buckets}})
                </div>
                <div class="card-body">
                    {{if .S3Buckets}}
                        {{range .S3Buckets}}
                            <div class="item">
                                <div class="item-name">{{.Name}}</div>
                                <div class="item-details">
                                    Created: <span class="badge">{{.CreationDate}}</span>
                                </div>
                            </div>
                        {{end}}
                    {{else}}
                        <div class="empty">No S3 buckets found</div>
                    {{end}}
                </div>
            </div>

            <div class="card">
                <div class="card-header iam">
                    👤 IAM Users ({{len .IAMUsers}})
                </div>
                <div class="card-body">
                    {{if .IAMUsers}}
                        {{range .IAMUsers}}
                            <div class="item">
                                <div class="item-name">{{.UserName}}</div>
                                <div class="item-details">
                                    Created: {{.CreateDate}}<br>
                                    <small style="color: #999;">{{.Arn}}</small>
                                </div>
                            </div>
                        {{end}}
                    {{else}}
                        <div class="empty">No IAM users found</div>
                    {{end}}
                </div>
            </div>

            <div class="card">
                <div class="card-header roles">
                    🔐 IAM Roles ({{len .IAMRoles}})
                </div>
                <div class="card-body">
                    {{if .IAMRoles}}
                        {{range .IAMRoles}}
                            <div class="item">
                                <div class="item-name">{{.RoleName}}</div>
                                <div class="item-details">
                                    Created: {{.CreateDate}}<br>
                                    <small style="color: #999;">{{.Arn}}</small>
                                </div>
                            </div>
                        {{end}}
                    {{else}}
                        <div class="empty">No IAM roles found</div>
                    {{end}}
                </div>
            </div>
        </div>
    </div>
</body>
</html>
`
