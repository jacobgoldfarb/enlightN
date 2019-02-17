import json
import logging
import pickle
import random
import traceback

from google.appengine.api import memcache


class memcacheWrapper(memcache.Client):
    def __init__(self):
        super(memcacheWrapper, self).__init__()
        self.max_memcache_byte_size = 500000

    def get_multipart(self, key):
        try:
            meta_info = json.loads(self.get(key))
        except:
            return None

        partition_count = meta_info['partition_count']
        is_pickled = meta_info['is_pickled']
        merged_partition_string = ""
        for i in range(partition_count):
            partition_key = key + "_" + str(i)
            partition_string = self.get(partition_key)
            if not partition_string:
                return None
            merged_partition_string += partition_string

        if is_pickled:
            merged_partition_string = pickle.loads(merged_partition_string)

        return merged_partition_string

    def set_multipart(self, key, value, timeout=0):
        is_pickled = False
        if type(value) not in [str, unicode]:
            value = pickle.dumps(value, -1)
            is_pickled = True
        partitioned_string = [value[i:i + self.max_memcache_byte_size] for i in
                              range(0, len(value), self.max_memcache_byte_size)]
        partition_count = len(partitioned_string)

        for i in range(partition_count):
            partition_key = key + "_" + str(i)
            self.set(partition_key, partitioned_string[i], timeout)

        return self.set(key, json.dumps({'partition_count': partition_count, 'is_pickled': is_pickled}), timeout)

    def delete_multipart(self, key):
        try:
            meta_info = json.loads(self.get(key))
        except:
            return None
        partition_count = meta_info['partition_count']

        for i in range(partition_count):
            partition_key = key + "_" + str(i)
            self.delete(partition_key)

        return self.delete(key)

    def get_replica(self, key, replication_count=10):
        try:
            key = '%s_%d' % (key, random.randint(0, replication_count - 1))
            return self.get(key)
        except:
            logging.error(traceback.format_exc())
            return None

    def set_replica(self, key, value, timeout=0, replication_count=10):
        try:
            mapping = {}
            for i in range(replication_count):
                mapping['%s_%d' % (key, i)] = str(value)
            self.set_multi(mapping, timeout)
        except:
            logging.error(traceback.format_exc())

    def delete_replica(self, key, replication_count=10):
        try:
            mapping = []
            for i in range(replication_count):
                mapping.append('%s_%d' % (key, i))
            self.delete_multi(mapping)
        except:
            logging.error(traceback.format_exc())
