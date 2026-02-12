# structured-bash-command-server
SBCS -- a structured facility for constructing agentic commands based on scraping documents from the World Wide Web.

## REQUIREMENTS
At the present, the web scraper requires `curl` and `htmlq` to be installed, and on path on the current user's
operating system. If you need to install them, some common shell command to do so are:

```bash Ubuntu
# for Ubuntu
apt install curl htmlq
```

```bash ArchLinux
# for ArchLinux
pacman -Syu
pacman -S curl htmlq
```

> Don't forget to add sudo, as needed, to elevate your permissions temporarily for installing system-level software.
>> Alternatively, you could also download binaries for `curl` and `htmlq`, but that's outside the scope of this README.

## HOW TO: Run the Web Scraper / HTML Formatter
There are standalone scripts that are currently in-development and contain hard-coded values for the request URL. This
points to a page for `nextjs` documentation. The script downloads the public page once using curl, then formats the
response using htmlq. The script works within a temporary directory, either /tmp or the "$HOME" directory as a fallback
(if /tmp cannot be accessed).

To run the script, which takes no arguments, using the following command in a terminal window, such as `Terminal` or 
`Command Prompt` or `cmd.exe`.

```bash Ghostty Terminal example
(base) greg@gb-linux:~$ cd <<your scripts directory>>
(base) greg@gb-linux:~/MyCode/scripts-bash$ ./scrape_web_data.sh
```

```bash example output
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100  777k    0  777k    0     0  7777k      0 --:--:-- --:--:-- --:--:-- 7777k
SUCCESS: The file /tmp/scrape/formatted_webpage.html was created.
```

After the web scraper has run and created temporary files, you can view and edit
them with a text editor like `nano`.

```bash nano example
# raw webpage output
(base) greg@gb-linux:~/MyCode/scripts-bash$ nano /tmp/scrape/download_webpage.html
# just the <p> element text contents, extracted and pretty-printed with htmlq.
(base) greg@gb-linux:~/MyCode/scripts-bash$ nano /tmp/scrape/formatted_webpage.html
```

You should see output from documentation that starts with the following section:

```text /tmp/scrape/formatted_webpage.html
Using App Router

Features available in /app

Latest Version
```
