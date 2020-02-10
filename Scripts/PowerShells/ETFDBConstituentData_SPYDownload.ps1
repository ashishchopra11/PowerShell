$login = Invoke-WebRequest https://etfdb.com/members/login -SessionVariable session;

$form = $login.Forms[2];
$form.Fields["amember_login"] = "us_ap@hcmlp.com";
$form.Fields["amember_pass"] = "H1ghland";
$form.Fields["redirect_url"] = "/"

$headers = @{}

$headers.Add("Accept", "text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8");
$headers.Add("Accept-Encoding", "gzip, deflate, br");
$headers.Add("Accept-Language", "en-US,en;q=0.9");
$headers.Add("Cache-Control", "max-age=0");
$headers.Add("Content-Type", "application/x-www-form-urlencoded");
$headers.Add("Host", "etfdb.com");
$headers.Add("Origin", "https://etfdb.com");
$headers.Add("Referer", "https://etfdb.com/members/login/?redirect_url=%2Fscreener");
$headers.Add("Upgrade-Insecure-Requests", "1")


$response = Invoke-WebRequest https://etfdb.com/members/login/ -Method POST -Headers $headers -Body $form.Fields  -WebSession $session -MaximumRedirection 0 -ErrorAction Ignore

Invoke-WebRequest http://etfdb.com/holdings-export/325/ -WebSession $session -OutFile \\services.hcmlp.com\DeliveryStore\EtfDB\SPY\holdings.csv