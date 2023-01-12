import requests

print("hello world")

URL = "https://172.16.94.10:6443"

data = requests.get(URL)

print(data.text())