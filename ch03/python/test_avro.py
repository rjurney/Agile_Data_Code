#!/usr/bin/env python

#
# derived from helpful example at http://www.harshj.com/2010/04/25/writing-and-reading-avro-data-files-using-python/
#
from avro import schema, datafile, io
import pprint

# Test writing avros
OUTFILE_NAME = '/tmp/messages.avro'

SCHEMA_STR = """{
    "type": "record",
    "name": "Message",
    "fields" : [
      {"name": "message_id", "type": "int"},
      {"name": "topic", "type": "string"},
      {"name": "user_id", "type": "int"}
    ]
}"""

SCHEMA = schema.parse(SCHEMA_STR)

# Create a 'record' (datum) writer
rec_writer = io.DatumWriter(SCHEMA)

# Create a 'data file' (avro file) writer
df_writer = datafile.DataFileWriter(
  open(OUTFILE_NAME, 'wb'),
  rec_writer,
  writers_schema = SCHEMA
)

df_writer.append( {"message_id": 11, "topic": "Hello galaxy", "user_id": 1} )
df_writer.append( {"message_id": 12, "topic": "Jim is silly!", "user_id": 1} )
df_writer.append( {"message_id": 23, "topic": "I like apples.", "user_id": 2} )
df_writer.close()

# Test reading avros
rec_reader = io.DatumReader()

# Create a 'data file' (avro file) reader
df_reader = datafile.DataFileReader(
  open(OUTFILE_NAME),
  rec_reader
)

# Read all records stored inside
pp = pprint.PrettyPrinter()
for record in df_reader:
  pp.pprint(record)
