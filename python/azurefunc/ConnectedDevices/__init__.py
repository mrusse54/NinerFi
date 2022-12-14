import logging
import os

import azure.functions as func

import pymongo
from bson.json_util import dumps

from collections import defaultdict


def main(req: func.HttpRequest) -> func.HttpResponse:
    logging.info('Python HTTP trigger function processed a request.')

    uri = "mongodb://localhost:27017"#os.environ["COSMOS_CONNECTION_STRING"]
    client = pymongo.MongoClient(uri)

    db = client.ninerfi
    collection = db.connected_devices

    latlng = defaultdict(dict)
    counts = defaultdict(int)

    result = collection.find({})
    for device in result:
        ap = db.access_points.find_one({"_id": device["access_point"]})
        counts[ap["building"]] += 1
        latlng[ap["building"]] = ap["coordinates"]

    body = { "buildings": []}

    for key, value in counts.items():
        body["buildings"].append({
            "building": key,
            "lat": latlng[key]["lat"],
            "lng": latlng[key]["lng"],
            "count": value
        })

    return func.HttpResponse(
        body=dumps(body),
        status_code=200,
        mimetype='text/json'
    )