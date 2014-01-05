#!/opt/local/bin/python

import imaplib
import sys, signal
from avro import schema, datafile, io
import os, re
import email
import inspect, pprint
import time

from email_utils import EmailUtils

class GmailSlurper(object):
  
  def __init__(self):
    self.utils = EmailUtils()
    """This class downloads all emails in folders from your Gmail inbox and writes them as raw UTF-8 text in simple Avro records for further processing."""
  
  def init_directory(self, directory):
    if os.path.exists(directory):
      print 'Warning: %(directory)s already exists:' % {"directory":directory}
    else:
      os.makedirs(directory)
    return directory
  
  def init_imap(self, username, password):
    self.username = username
    self.password = password
    try:
      imap.shutdown()
    except:
      pass
    try:
      self.imap = imaplib.IMAP4_SSL('imap.gmail.com', 993)
      self.imap.login(username, password)
      self.imap.is_readonly = True
    except:
      pass
  
  # part_id will be helpful one we're splitting files among multiple slurpers
  def init_avro(self, output_path, part_id, schema_path):
    output_dir = None
    output_dirtmp = None	# Handle Avro Write Error 
    if(type(output_path) is str):
      output_dir = self.init_directory(output_path)
      output_dirtmp = self.init_directory(output_path + 'tmp') # Handle Avro Write Error
    out_filename = '%(output_dir)s/part-%(part_id)s.avro' % \
      {"output_dir": output_dir, "part_id": str(part_id)}
    out_filenametmp = '%(output_dirtmp)s/part-%(part_id)s.avro' % \
      {"output_dirtmp": output_dirtmp, "part_id": str(part_id)}  # Handle Avro Write Error
    self.schema = open(schema_path, 'r').read()
    email_schema = schema.parse(self.schema)
    rec_writer = io.DatumWriter(email_schema)
    self.avro_writer = datafile.DataFileWriter(
      open(out_filename, 'wb'),
      rec_writer,
      email_schema
    )
    # CREATE A TEMP AvroWriter that can be used to workaround the UnicodeDecodeError when writing into AvroStorage
    self.avro_writertmp = datafile.DataFileWriter(
 	    open(out_filenametmp, 'wb'),
      rec_writer,
      email_schema
    )
  
  def init_folder(self, folder):
    self.imap_folder = folder
    status, count = self.imap.select(folder)      
    print "Folder '" + str(folder) + "' SELECT status: " + status
    if(status == 'OK'):
      count = int(count[0])
      ids = range(1,count)
      ids.reverse()
      self.id_list = ids
      print "Folder '" + str(folder) + " has " + str(count) + "' emails...\n"
      self.folder_count = count
    return status, count
  
  def fetch_email(self, email_id):
    def timeout_handler(signum, frame):
      raise self.TimeoutException()
    
    signal.signal(signal.SIGALRM, timeout_handler) 
    signal.alarm(30) # triger alarm in 30 seconds
    
    avro_record = dict()
    status = 'FAIL'
    try:
      status, data = self.imap.fetch(str(email_id), '(X-GM-THRID RFC822)') # Gmail's X-GM-THRID will get the thread of the message
    except self.TimeoutException:
      return 'TIMEOUT', {}, None
    except:
      return 'ABORT', {}, None
    
    charset = None
    if status != 'OK':
      return 'ERROR', {}, None
    else:
      raw_thread_id = data[0][0]
      encoded_email = data[0][1]
    
    try:
      charset = self.utils.get_charset(encoded_email)
      
      # RFC2822 says default charset is us-ascii, which often saves us when no charset is specified
      if(charset):
        pass
      else:
        charset = 'us-ascii'
      
      if(charset): # redundant, but saves our ass if we edit above
        #raw_email = encoded_email.decode(charset)
        thread_id = self.utils.get_thread_id(raw_thread_id)
        print "CHARSET: " + charset
        avro_record, charset = self.utils.process_email(encoded_email, thread_id)
      else:
        return 'UNICODE', {}, charset
    except UnicodeDecodeError:
      return 'UNICODE', {}, charset
    except:
      return 'ERROR', {}, None
    
    # Without a charset we pass bad chars to avro, and it dies. See AVRO-565.
    if charset:
      return status, avro_record, charset
    else:
      return 'CHARSET', {}, charset
  
  def shutdown(self):
    self.avro_writer.close()
    self.avro_writertmp.close()	# Handle Avro write errors
    self.imap.close()
    self.imap.logout()
  
  def write(self, record):
    #self.avro_writer.append(record)
    # BEGIN - Handle errors when writing into Avro storage
    try:
    	self.avro_writertmp.append(record)
    	self.avro_writer.append(record)
    		
    except UnicodeDecodeError:
    	sys.stderr.write("ERROR IN Writing EMAIL to Avro for UnicodeDecode issue, SKIPPED ONE\n")
    	pass
    	
    except:
    	pass
  	# END - Handle errors when writing into Avro storage
  
  def flush(self):
    self.avro_writer.flush()
    self.avro_writertmp.flush()	# Handle Avro write errors
    print "Flushed avro writer..."
  
  def slurp(self):
    if(self.imap and self.imap_folder):
      for email_id in self.id_list:
        (status, email_hash, charset) = self.fetch_email(email_id)
        if(status == 'OK' and charset and 'thread_id' in email_hash and 'from' in email_hash):
          print email_id, charset, email_hash['thread_id']
          self.write(email_hash)
          if((int(email_id) % 1000) == 0):
            self.flush()
        elif(status == 'ERROR' or status == 'PARSE' or status == 'UNICODE' or status == 'CHARSET' or status =='FROM'):
          sys.stderr.write("Problem fetching email id " + str(email_id) + ": " + status + "\n")
          continue
        elif (status == 'ABORT' or status == 'TIMEOUT'):
          sys.stderr.write("resetting imap for " + status + "\n")
          stat, c = self.reset()
          sys.stderr.write("IMAP RESET: " + str(stat) + " " + str(c) + "\n")
        else:
          sys.stderr.write("ERROR IN PARSING EMAIL, SKIPPED ONE\n")
          continue
  
  def reset(self):
    self.init_imap(self.username, self.password)
    try:
      status, count = self.init_folder(self.imap_folder)
    except:
      self.reset()
      status = 'ERROR'
      count = 0
    return status, count
  
  class TimeoutException(Exception): 
    """Indicates an operation timed out."""
    sys.stderr.write("Timeout exception occurred!\n")
    pass
