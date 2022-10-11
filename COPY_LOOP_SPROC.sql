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
        FROM @acoustic.auto_ingest.BTCSTREAM/2022/10/11
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

call acoustic.auto_ingest.copy_loop();