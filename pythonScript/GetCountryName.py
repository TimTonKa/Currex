import json

# 讀取 JSON 檔案
with open("Country.json", "r", encoding="utf-8") as f:
    data = json.load(f)

# 輸出 country_name
for country_data in data.values():
    country_name = country_data.get("country_name")
    if country_name:
        with open("output.txt", "w", encoding="utf-8") as out:
          for country_data in data.values():
            country_name = country_data.get("country_name")
            if country_name:
              out.write(f'"country_name": "{country_name}",\n')