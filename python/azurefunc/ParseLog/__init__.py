import logging
import re
import os

import azure.functions as func

import pymongo

def find_bldg_from_id(ap):
    bldg = re.search("(^[A-Za-z]+)", ap)[0]

    uri = "mongodb://localhost:27017/ninerfi"# os.environ["COSMOS_CONNECTION_STRING"]
    client = pymongo.MongoClient(uri)

    db = client.ninerfi
    collection = db.access_points

    result = collection.find_one({"prefix": bldg})
    if (result):
        return result['_id']
    
    if (collection.count_documents({"prefix": ""}) > 0):
        result = collection.find({"prefix": ""})
        for doc in result:
            if (doc['building'].startswith(bldg)):
                collection.update_one({"_id": doc['_id']}, {"$set": {"prefix": bldg}})
                return doc['_id']
    
    logging.info('MANUAL --- ' + bldg)
    return None


def main(req: func.HttpRequest) -> func.HttpResponse:
    logging.info('Python HTTP trigger function processed a request.')

    log_batch = req.params.get('log_batch')
    if not log_batch:
        try:
            req_body = req.get_json()
        except ValueError:
            pass
        else:
            try:
                log_batch = req_body['log_batch']
            except KeyError:
                pass

    if log_batch:

        for log in list(log_batch):
            logging.info(f'{log}')

            entered_ap = re.search("<\s(?:[0-9]{1,3}\.){3}[0-9]{1,3}>\s\s(Assoc success) @ .{17}(.{17}).+?AP.+?(?:EXT-)?((?:[A-Za-z]){3,}[^\s]+)", log['log'])
            exited_ap = re.search("<\s(?:[0-9]{1,3}\.){3}[0-9]{1,3}>\s\s(Deauth to sta): (.{17}).+?AP.+?(?:EXT-)?((?:[A-Za-z]){3,}[^\s]+)", log['log'])

            if (entered_ap):
                uri = "mongodb://localhost:27017/ninerfi"#os.environ["COSMOS_CONNECTION_STRING"]
                client = pymongo.MongoClient(uri)

                db = client.ninerfi
                collection = db.connected_devices

                mac_address = entered_ap[2]
                ap = entered_ap[3]

                apId = find_bldg_from_id(ap)

                if (apId):
                    collection.update_one({"mac_address": mac_address}, {"$set": {
                        "access_point": apId
                    }}, upsert=True)

                    logging.info(f'Access Point {ap} count updated.')
            
            elif (exited_ap):
                uri = "mongodb://localhost:27017/ninerfi"#os.environ["COSMOS_CONNECTION_STRING"]
                client = pymongo.MongoClient(uri)

                db = client.ninerfi
                collection = db.connected_devices

                mac_address = exited_ap[2]
                ap = exited_ap[3]

                apId = find_bldg_from_id(ap)

                if (apId):
                    result = collection.delete_one({"mac_address": mac_address})

                    if (result.deleted_count > 0): logging.info(f'Access Point {ap} count updated.')
            
            else:
                pass

        return func.HttpResponse(
                    "Log batch parsed successfully.",
                    status_code=200
        )

    else:
        return func.HttpResponse(
             "No log batch provided in request body.",
             status_code=400
        )
