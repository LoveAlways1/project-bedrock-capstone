import json
import urllib.parse


def lambda_handler(event, context):
    print("Received event:", json.dumps(event))

    records = event.get("Records", [])

    for record in records:
        bucket_name = record.get("s3", {}).get("bucket", {}).get("name", "")
        object_key = record.get("s3", {}).get("object", {}).get("key", "")
        decoded_key = urllib.parse.unquote_plus(object_key)

        print(f"Image received: {decoded_key}")
        print(f"Bucket: {bucket_name}")

    return {
        "statusCode": 200,
        "body": json.dumps({
            "message": "Asset event processed",
            "recordsProcessed": len(records)
        })
    }
