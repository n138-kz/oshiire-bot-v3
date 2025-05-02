<?php
session_start([
	'name'=>'session_id'
]);

$_SESSION['user_id']=isset($_SESSION['user_id'])?$_SESSION['user_id']:null;

$config['internal']['announce']['file']['path']=__DIR__.'/../discord_json_announcements/_announce.json';
$config['internal']['announce']['file']['path']=is_file($config['internal']['announce']['file']['path'])?realpath($config['internal']['announce']['file']['path']):'';
$config['internal']['jsonparse']['encode']=JSON_PRETTY_PRINT|JSON_NUMERIC_CHECK|JSON_UNESCAPED_SLASHES|JSON_UNESCAPED_UNICODE|JSON_INVALID_UTF8_IGNORE|JSON_INVALID_UTF8_SUBSTITUTE|JSON_THROW_ON_ERROR;

$content=isset($_POST['content'])?$_POST['content']:null;
$content_json=json_decode($content,true);
?><!DOCTYPE html><html lang="ja">
<head>
	<meta charset="utf-8">
	<meta http-equiv="refresh" content="300">
	<link rel="stylesheet" href="https://n138-kz.github.io/lib/master.css?t=0">
	<script src="https://n138-kz.github.io/lib/master.js"></script>
	<title>_announce.json editor</title>
	<style>
		form textarea {
			width: 90%;
			min-height: 10em;
			background-color: black;
			color: white;
		}
	</style>
	<script>
		console.log('');
		function send(calledby){
			console.log(calledby);
		}
	</script>
	<script>
		console.log('');
	</script>
</head>
<body>
	<form action="" method="POST">
		<fieldset>
			<legend>_announce.json</legend>
			<textarea name="content"><?php echo json_encode(json_decode(file_get_contents($config['internal']['announce']['file']['path'])),JSON_PRETTY_PRINT|JSON_NUMERIC_CHECK|JSON_UNESCAPED_SLASHES|JSON_UNESCAPED_UNICODE|JSON_INVALID_UTF8_IGNORE|JSON_INVALID_UTF8_SUBSTITUTE|JSON_THROW_ON_ERROR);?></textarea>
		</fieldset>
		<fieldset>
			<input type="datetime-local" value="<?php echo date('Y-m-d\TH:i:s');?>" id="datetime_to_epoch11" onchange="console.log(this.value);document.querySelector('#datetime_to_epoch12').value=new Date(this.value).getTime()/10**3"> → <input type="text" value="<?php echo time();?>" readonly id="datetime_to_epoch12">
		</fieldset>
		<fieldset>
			<table>
				<tr>
					<th></th>
					<th></th>
				</tr>
				<tr>
					<td></td>
					<td><code>:new:</code></td>
				</tr>
				<tr>
					<td></td>
					<td><code>:tada:</code></td>
				</tr>
			</table>
		</fieldset>
		<input type="button" value="check&submit" onclick="send(this)">
		<input type="submit" value="check&submit">
		<fieldset>
			<legend>$_POST</legend>
			<textarea><?php echo htmlspecialchars(json_encode($_POST,$config['internal']['jsonparse']['encode']));?></textarea>
		</fieldset>
		<fieldset>
			<legend>json</legend>
			<textarea><?php echo htmlspecialchars(json_encode($content_json,$config['internal']['jsonparse']['encode']));?></textarea>
		</fieldset>
	</form>
</body>
</html>
