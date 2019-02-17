import logging

import model
import utils


class SourceInfo(object):
    def __init__(self):
        pass

    def create(self, **data):
        self.check_validity(method='create', data=data)

        source_info, source_info_exists = self.get_datastore_entity(data)
        source_info.put()

    @staticmethod
    def read(debug=False, **filters):
        query_string = "SELECT * FROM SourceInfo"

        filters = {key: val for key, val in filters.iteritems() if val != None}

        i = 0
        for field in filters:
            if i == 0:
                query_string += " where "

            if i < len(filters) - 1:
                query_string += "%s='%s' and " % (field, filters[field])
            else:
                query_string += "%s='%s'" % (field, filters[field])
            i += 1

        response = utils.fetch_gql(query_string)
        if debug:
            logging.error("Query String: %s\n\n Response Length: %s" % (query_string, len(response)))

        return response

    @staticmethod
    def get_json_object(datastore_entity):
        json_object = {
            "domain": datastore_entity.domain,
            "host_name": datastore_entity.host_name,
            "credibility_status": datastore_entity.credibility_status,
            "tags": datastore_entity.tags,
            "modified_at": datastore_entity.modified_at.strftime('%Y-%m-%d %H:%M:%S'),
            "created_at": datastore_entity.created_at.strftime('%Y-%m-%d %H:%M:%S'),
        }

        return json_object

    @staticmethod
    def get_datastore_entity(json_object):
        entity_exists = True
        key_name = json_object["host_name"]
        datastore_entity = model.SourceInfo.get_by_key_name(key_name)
        if not datastore_entity:
            entity_exists = False
            datastore_entity = model.SourceInfo(key_name=key_name)

        datastore_entity.host_name = json_object["host_name"]
        datastore_entity.domain = json_object["domain"]
        datastore_entity.credibility_status = json_object["credibility_status"]
        datastore_entity.tags = json_object["tags"]

        return datastore_entity, entity_exists

    @staticmethod
    def check_validity(method, data):
        error = []

        if error:
            raise Exception(error)
