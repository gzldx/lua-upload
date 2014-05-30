<html>

<head>
    <title>upload file</title>
    <meta http-equiv="content-type" content="text/html; charset=UTF-8"/>
</head>

<body>
<h1>测试页面</h1>
<form action="/upload/background" method="post" enctype="multipart/form-data">
    uid: <input type="text" name="uid" />
    status: <input type="text" name="status" />
    <input type="file" name="file" />
    <input type="submit" name="submit" value="提交" />
</form>

</body>

</html>
