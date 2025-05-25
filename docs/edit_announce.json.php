<?php session_start([
	'name'=>'session_id'
]);
date_default_timezone_set('Asia/Tokyo');

header('Server: Hidden');
header('X-Powered-By: Hidden');

$_SESSION['user_id']=isset($_SESSION['user_id'])?$_SESSION['user_id']:null;

$config['internal']['announce']['file']['path']=__DIR__.'/../discord_json_announcements/_announce.json';
$config['internal']['announce']['file']['path']=is_file($config['internal']['announce']['file']['path'])?realpath($config['internal']['announce']['file']['path']):'';
$config['internal']['jsonparse']['encode']=JSON_PRETTY_PRINT|JSON_NUMERIC_CHECK|JSON_UNESCAPED_SLASHES|JSON_UNESCAPED_UNICODE|JSON_INVALID_UTF8_IGNORE|JSON_INVALID_UTF8_SUBSTITUTE|JSON_THROW_ON_ERROR;
$config['internal']['redirect']['url']='./'.preg_replace('/\.php$/', '.html', basename(__FILE__));

if(mb_strtolower($_SERVER['REQUEST_METHOD'])!='post'){
	http_response_code(302);
	header('location: '.$config['internal']['redirect']['url']);
	exit(1);
}

$content=isset($_POST['content'])?$_POST['content']:null;
$content_json=json_decode($content,true);

if(!$content_json){
	http_response_code(302);
	header('location: '.$config['internal']['redirect']['url']);
	exit(1);
}


file_put_contents($config['internal']['announce']['file']['path'].'.unsafe.json', json_encode($content_json, $config['internal']['jsonparse']['encode']), LOCK_EX);
http_response_code(302);
header('location: '.$config['internal']['redirect']['url']);
exit(0);
