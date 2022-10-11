# snowflake-constant-copy-into-sproc

Snowpipe runs on a trigger via SNS/SQS AWS messaging service. Oftentimes customers need/require a much lower latency of data ingestion for data that slowly trickles into S3. This stored procedure is meant to address these issues.

<b style='text-color:red'> Warning: </b> This is not <i>best practice</i> or an advised solution to follow. Please calculate all necessary costs prior to implementation and all code is provided <b style='color:red'>as is</b>.

### Main Stored Procedure
The stored procedure <b>copy_loop</b> will trigger a COPY INTO statement after a previous COPY INTO statement has completed. In short the code is provided below.

The code base runs an infinite loop in a Snowflake Stored Procedure in 3 major steps.

<b>1) COPY INTO</b> - Copy any new data into snowflake from the stage
<b>2) Save Results to Status Table</b> - After COPY INTO has completed a status is saved to a Snowflake table
<b>3) Wait</b> - Wait a pre-defined set of seconds prior to running next COPY INTO statement. Currently 3 seconds.


```javascript

create or replace procedure acoustic.auto_ingest.copy_loop()
returns string
language javascript
strict
execute as owner
as
$$
var status = {}

var i = 0
while( i < 30000){
    i = i + 1; // INCREMENT TOWARD END

    // CREATE COPY INTO SQL STATEMENT - CAN BE DYNAMIC
    var insertSQL = `
        COPY INTO acoustic.auto_ingest.TRADES
        FROM @YOUR_STAGE
             file_format = (TYPE = JSON);
    `;

    //RUN COPY INTO STATEMENT
    var rs = snowflake.execute ( {sqlText: insertSQL} );

    rs.next(); //GET RESULT OF COPY INTO
    var file = rs.getColumnValue(1);
    
    //save status to status table
    var sql_command = ` insert into acoustic.auto_ingest.status 
        select( PARSE_JSON('{t: "'||current_timestamp()||'", file: "${file}" }') ); `;
        
    //SAVE ROW TO TABLE
    snowflake.execute ( {sqlText: sql_command} );

    //WAIT 3 SECONDS BEFORE NEXT RUN
    snowflake.execute ( {sqlText: `select SYSTEM$WAIT(3);` } );
}
return ( i )

$$
;

```

### Set-Up DDL
Please see set-up DDL file for any set up scripts. 