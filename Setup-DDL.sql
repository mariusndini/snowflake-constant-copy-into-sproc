// Create DB & Schema
create database acoustic;
create schema acoustic.auto_ingest;

use database acoustic;
use schema auto_ingest;

//Create status table
create table acoustic.auto_ingest.status (data variant);

//Check status as necessary
select * from acoustic.auto_ingest.status;

//Get table row count - this is the table where rows are ingested into
select count(*)
from acoustic.auto_ingest.TRADES;

//create stage
CREATE OR REPLACE STAGE acoustic.auto_ingest.BTCSTREAM
    URL = 's3://btcstream' 
    CREDENTIALS = (AWS_KEY_ID = 'Key ID' 
                   AWS_SECRET_KEY = 'Secret Key');



//create trades table where data is streamed into
create or replace TABLE acoustic.auto_ingest.TRADES ( V VARIANT );












