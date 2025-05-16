import json

# 讀取原始 JSON 檔案
with open("Country.json", "r", encoding="utf-8") as f:
    raw_data = json.load(f)

# 產出新格式的資料
output = {}

for item in raw_data.values():
    country_name = item.get("country_name")
    if country_name:
        output[country_name] = {
            "extractionState": "manual",
            "localizations": {
                "en": {
                    "stringUnit": {
                        "state": "translated",
                        "value": country_name
                    }
                },
                "zh-Hant": {
                    "stringUnit": {
                        "state": "translated",
                        "value": ""  # 這裡可以補上中文翻譯（你有的話）
                    }
                }
            }
        }

# 寫入新的 JSON 檔案
with open("output2.json", "w", encoding="utf-8") as f:
    json.dump(output, f, indent=2, ensure_ascii=False)

print("轉換完成，輸出已儲存為 output.json")
