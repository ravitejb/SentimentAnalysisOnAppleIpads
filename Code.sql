/*Run the below query in Hive*/
ADD JAR hdfs:///user/hive/lib/json-serde-1.3.7-jar-with-dependencies.jar;
CREATE EXTERNAL TABLE metadata (asin string,  
				title string,
				description string,
				price double,
				imUrl string, 
				related struct<also_bought:array<string>, 
						also_viewed:array<string>, 
						bought_together:array<string>>, 
				salesrank string, 
				brand string, 
				categories array<string>)
ROW FORMAT SERDE 'org.openx.data.jsonserde.JsonSerDe'
LOCATION '/user/root/metadata/';

ALTER TABLE metadata SET SERDEPROPERTIES ( "ignore.malformed.json" = "true"); 

/*We are altering the above table as we have some corrupted data in the downloaded metadata file.*/

/*Run the below query in HIVE to access the data from Impala */
create table metadata_impala as  SELECT  
    cast(asin as string), 
	cast(title as string), 
	cast(price as float), 
	cast(imurl as string),
    cast(concat_ws(',', COALESCE(related.also_viewed)) AS string) AS also_viewed, 
	cast(concat_ws(',', COALESCE(related.also_bought)) AS string) AS also_bought,
    cast(concat_ws(',', COALESCE(related.bought_together)) AS string) AS bought_together,
	cast(regexp_replace(SPLIT(salesrank,':')[0],'(\\{")|(\\")','') as string) AS salesrank_in_dept , 
	cast(regexp_replace(SPLIT(salesrank,':')[1],'(\\"})|(\\")','') AS bigint) AS salesrank,
    cast(brand as string),
	cast(concat_ws(',',COALESCE(categories[0]))  as string) AS categories 
FROM metadata;

/*Run the below query in HIVE to load the reviews data in HIVE*/
ADD JAR hdfs:///user/hive/lib/json-serde-1.3.7-jar-with-dependencies.jar;
CREATE EXTERNAL TABLE full_reviews (reviewerID string,  
asin string, 
reviewerName string, 
helpful array<int>, 
reviewText string, 
overall double, 
summary string, 
unixReviewTime bigint, 
reviewTime string)
ROW FORMAT SERDE 'org.openx.data.jsonserde.JsonSerDe'
LOCATION '/user/root/full_reviews/';

/*Run the below query in HIVE to access the data from Impala*/

CREATE TABLE full_reviews_impala AS SELECT 
reviewerid, 
reviewername, 
asin, 
summary, 
overall, 
helpful[0] AS helpfulup, 
helpful[1] AS helpfuldown, 
unixreviewtime, 
reviewtime, 
reviewtext 
FROM full_reviews;

/*Collect Data related Apple Products */

create table apple_ids as select * from metadata_impala where brand like 'Apple%' order by brand asc

/*Collect Apple reviews data */
CREATE TABLE apple_review_data AS SELECT 
t1.*, 
t2.title, 
t2.price,
t2.also_viewed, 
t2.also_bought, 
t2.bought_together, 
t2.salesrank_in_dept, 
t2.salesrank, 
t2.brand, 
t2.categories 
FROM amazon_reviews_impala t1, apple_ids t2 
WHERE t1.asin = t2.asin 

/*Collect Data related to only iPads */
SELECT asin, 
title, 
summary, 
helpfulup, 
helpfuldown, 
overall, 
price, 
brand, 
reviewtext 
FROM apple_review_data 
WHERE title LIKE 'Apple iPad%' 
AND title NOT LIKE '%Cover%' 
AND title NOT LIKE '%Case%' 
AND title NOT LIKE '%Kit%'

/*Save this as a EXCEL file from HUE browser and take subsets of each iPad and add it to each sheet.*/

 
