<?php session_start([
	'name'=>'session_id'
]);
date_default_timezone_set('Asia/Tokyo');

header('Server: Hidden');
header('X-Powered-By: Hidden');

$_SESSION['user_id']=isset($_SESSION['user_id'])?$_SESSION['user_id']:null;

$config = [];
$config['internal'] = [];
$config['internal']['config'] = [];
$config['internal']['config']['filename'] = '../.secret/config.json';
if(!file_exists($config['internal']['config']['filename'])){
	http_response_code(500);
	$result['result']=[
		'id'=>1,
		'level'=>'Fatal',
		'description'=>'Config load failed: No such file or directory: `'.$config['internal']['config']['filename'].'`',
	];
	error_log($result['result']['level'].': '.$result['result']['description'].' evented on '.__FILE__.'#'.__LINE__);
	echo json_encode($result['result'],JSON_PRETTY_PRINT|JSON_INVALID_UTF8_IGNORE|JSON_UNESCAPED_UNICODE);
	exit(1);
}
if(!is_readable($config['internal']['config']['filename'])){
	http_response_code(500);
	$result['result']=[
		'id'=>1,
		'level'=>'Fatal',
		'description'=>'Config load failed: Permission denied: `'.$config['internal']['config']['filename'].'`',
	];
	error_log($result['result']['level'].': '.$result['result']['description'].' evented on '.__FILE__.'#'.__LINE__);
	echo json_encode($result['result'],JSON_PRETTY_PRINT|JSON_INVALID_UTF8_IGNORE|JSON_UNESCAPED_UNICODE);
	exit(1);
}

$config = array_merge($config, json_decode(file_get_contents($config['internal']['config']['filename']), TRUE));
$config['internal']['announce']['file']['path']=__DIR__.'/../discord_json_announcements/_announce.json';
$config['internal']['announce']['file']['path']=is_file($config['internal']['announce']['file']['path'])?realpath($config['internal']['announce']['file']['path']):'';
$config['internal']['jsonparse']['encode']=JSON_PRETTY_PRINT|JSON_NUMERIC_CHECK|JSON_UNESCAPED_SLASHES|JSON_UNESCAPED_UNICODE|JSON_INVALID_UTF8_IGNORE|JSON_INVALID_UTF8_SUBSTITUTE|JSON_THROW_ON_ERROR;
$config['internal']['redirect']['url']=$_SERVER['REQUEST_SCHEME'].'://'.$_SERVER['SERVER_NAME'].preg_replace('/\.php$/', '.html', $_SERVER['PHP_SELF']);
$config['external']=(isset($config['external']))?$config['external']:[];
$config['external']['discord']=(isset($config['external']['discord']))?$config['external']['discord']:[];
$config['external']['discord']['webhook']=(isset($config['external']['discord']['webhook']))?$config['external']['discord']['webhook']:[];
$config['external']['discord']['webhook']['notice']=(isset($config['external']['discord']['webhook']['notice'])&&$config['external']['discord']['webhook']['notice']!=='')?$config['external']['discord']['webhook']['notice']:'';

if(mb_strtolower($_SERVER['REQUEST_METHOD'])!='post'){
	http_response_code(302);
	header('location: '.$config['internal']['redirect']['url']);
	exit(1);
}

# discord userme/*
$discord_userme = [];

# access_token
$discord_access_token=isset($_POST['discord_access_token'])?$_POST['discord_access_token']:null;
if(is_null($discord_access_token)){
	http_response_code(401);
	header('location: '.$config['internal']['redirect']['url']);
	exit(1);
}
$curl_req=curl_init('https://discordapp.com/api/users/@me');
curl_setopt($curl_req, CURLOPT_HTTPHEADER, ['Authorization: Bearer '.$discord_access_token]);
curl_setopt($curl_req, CURLOPT_RETURNTRANSFER, TRUE);
curl_setopt($curl_req, CURLOPT_FOLLOWLOCATION, TRUE);
$curl_result=curl_exec($curl_req);
$curl_result=json_decode($curl_result, TRUE);
$curl_error=curl_error($curl_req);
$curl_info=curl_getinfo($curl_req);
$curl_result=($curl_result=='')?null:$curl_result;
$curl_error=($curl_error=='')?null:$curl_error;
$curl_result=[
	'result' => $curl_result,
	'error'  => $curl_error,
	'info'   => $curl_info,
];
$list=['id', 'username', 'avatar'];
foreach($list as $k => $v) {
	if(!isset($curl_result['result'][$v])){
		http_response_code(401);
		$result['result']=[
			'id'=>1,
			'level'=>'Fatal',
			'description'=>'Unauthorized(401)',
		];
		error_log($result['result']['level'].': '.$result['result']['description'].' evented on '.__FILE__.'#'.__LINE__);
		header('location: '.$config['internal']['redirect']['url']);
		exit(1);
	}
}
$discord_userme = $curl_result['result'];

# Guild(Discord Server)
$curl_req=curl_init('https://discordapp.com/api/users/@me/guilds');
curl_setopt($curl_req, CURLOPT_HTTPHEADER, ['Authorization: Bearer '.$discord_access_token]);
curl_setopt($curl_req, CURLOPT_RETURNTRANSFER, TRUE);
curl_setopt($curl_req, CURLOPT_FOLLOWLOCATION, TRUE);
$curl_result=curl_exec($curl_req);
$curl_result=json_decode($curl_result, TRUE);
$curl_error=curl_error($curl_req);
$curl_info=curl_getinfo($curl_req);
$curl_result=($curl_result=='')?null:$curl_result;
$curl_error=($curl_error=='')?null:$curl_error;
$curl_result=[
	'result' => $curl_result,
	'error'  => $curl_error,
	'info'   => $curl_info,
];
file_put_contents('detail.json', json_encode($curl_result, $config['internal']['jsonparse']['encode']), LOCK_EX);

# BODY
$content=isset($_POST['content'])?$_POST['content']:null;
$content_json=json_decode($content,true);

if(!$content_json){
	http_response_code(302);
	header('location: '.$config['internal']['redirect']['url']);
	exit(1);
}

# push to discord
$discord_webhook_url = $config['external']['discord']['webhook']['notice'];
$discord_post_payloadjson = [
	'avatar_url' => 'https://cdn.discordapp.com/embed/avatars/1.png',
	'username' => $_SERVER['SERVER_NAME'],
	'embeds' => [],
];
$discord_post_embed = [
	'title' => basename(__FILE__),
	'url' => $config['internal']['redirect']['url'],
	'color' => hexdec('ffa500'),
	'fields' => [],
];
$discord_post_fields = [
	[
		'name' => '',
		'value' => '',
		'inline' => false,
	],
];

/* */
	$discord_post_fields[] = [
		'name' => '$content_json',
		'value' => 'content_json',
		'inline' => false,
	];
/* */
$discord_post_embed['fields'] = $discord_post_fields;
$discord_post_payloadjson['embeds'][] = $discord_post_embed;
file_put_contents('payload.json', json_encode($discord_post_payloadjson), LOCK_EX);

$curl_req=curl_init($discord_webhook_url);
curl_setopt($curl_req, CURLOPT_POST, TRUE);
curl_setopt($curl_req, CURLOPT_HTTPHEADER, ['Content-Type: application/json']);
curl_setopt($curl_req, CURLOPT_POSTFIELDS, json_encode($discord_post_payloadjson));
curl_setopt($curl_req, CURLOPT_RETURNTRANSFER, TRUE);
curl_setopt($curl_req, CURLOPT_FOLLOWLOCATION, TRUE);
$curl_result=curl_exec($curl_req);
$curl_result=json_decode($curl_result, TRUE);
$curl_error=curl_error($curl_req);
$curl_info=curl_getinfo($curl_req);
$curl_result=($curl_result=='')?null:$curl_result;
$curl_error=($curl_error=='')?null:$curl_error;
$curl_result=[
	'config' => $config,
	'webhook'=> $discord_webhook_url,
	'payload'=> $discord_post_payloadjson,
	'request'=> $curl_req,
	'result' => $curl_result,
	'error'  => $curl_error,
	'info'   => $curl_info,
];

file_put_contents('detail.json', json_encode($curl_result, $config['internal']['jsonparse']['encode']), LOCK_EX);
file_put_contents($config['internal']['announce']['file']['path'].'.unsafe.json', json_encode($content_json, $config['internal']['jsonparse']['encode']), LOCK_EX);
http_response_code(302);
header('location: '.$config['internal']['redirect']['url'].'?access_token='.$discord_access_token.'&uuid='.$_SERVER['UNIQUE_ID']);
exit(0);
