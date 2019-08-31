# hadoop_spark_hive

# How to use hadoop_spark_hive

To start hadoop_spark_hive:
```
    go the folder and run docker-compose build and docker-compose up -d
```
It will start the container

```
## Example for Spark using hive

./pyspark -conf spark.ui.port=4050

from pyspark import SparkContext, SparkConf
from pyspark.sql import SparkSession, HiveContext
SparkContext.setSystemProperty("hive.metastore.uris", "thrift://localhost:9083")
sparkSession = (SparkSession.builder.appName('pyspark').enableHiveSupport().getOrCreate())
data = [('First', 1), ('Second', 2), ('Third', 3), ('Fourth', 4), ('Fifth', 5)]
df = sparkSession.createDataFrame(data)
df.write.saveAsTable('example')
df_load = sparkSession.sql('SELECT * FROM example')
df_load.show()
    
```