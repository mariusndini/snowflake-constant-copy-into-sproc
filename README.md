# snowflake-constant-copy-into-sproc

Snowpipe runs on a trigger via SNS/SQS AWS messaging service. Oftentimes customers need/require a much lower latency of data ingestion for data that slowly trickles into S3. This stored procedure is meant to address these issues.

<b> Warning: </b> This is not <i>best practice</i> or an advised solution to follow. Please calculate all necessary costs prior to implementation and all code is provided <b>as is</b>.
