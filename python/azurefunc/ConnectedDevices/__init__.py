import logging
import os

import azure.functions as func

import pymongo
from bson.json_util import dumps


def main(req: func.HttpRequest) -> func.HttpResponse:
    logging.info('Python HTTP trigger function processed a request.')

    uri = os.environ["COSMOS_CONNECTION_STRING"]
    client = pymongo.MongoClient(uri)

    db = client.ninerfi
    collection = db.connected_devices

    result = dumps(collection.aggregate([
        {'$group' : { '_id': '$access_point.building', 'count': {'$sum': 1}}}]
    ))

    return func.HttpResponse(
        body=result,
        status_code=200,
        mimetype='text/json'
    )