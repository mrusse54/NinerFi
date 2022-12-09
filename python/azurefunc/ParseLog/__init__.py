import logging
import re
import os

import azure.functions as func

import pymongo


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
                uri = os.environ["COSMOS_CONNECTION_STRING"]
                client = pymongo.MongoClient(uri)

                db = client.ninerfi
                collection = db.connected_devices

                mac_address = entered_ap[2]
                ap = entered_ap[3]

                collection.update_one({"mac_address": mac_address}, {"$set": {
                    "access_point": {
                        "id": ap,
                        "building": re.search("(^[A-Za-z]+)", ap)[0]
                    }
                }}, upsert=True)

                logging.info(f'Access Point {ap} count updated.')
            
            elif (exited_ap):
                uri = os.environ["COSMOS_CONNECTION_STRING"]
                client = pymongo.MongoClient(uri)

                db = client.ninerfi
                collection = db.connected_devices

                mac_address = exited_ap[2]
                ap = exited_ap[3]

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
