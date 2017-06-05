# SentimentAnalysisOnAppleIpads

Sentiment analysis on Apple iPads(different versions including ipad2, iPad AIR, iPad 3rd Gen, iPad MINI, iPad 4)
** Sentiment Analysis Code can be modified to any other use case based on the requirement with small tweaks**
** A comparision of analysis is done between Dunkin Donuts, McDonalds, Starbucks from Twitter Data**
Data Extraction:

In terminal inside docker container,

Download both metadata and reviews of electronics file as below

curl -L -O -C - http://snap.stanford.edu/data/amazon/productGraph/categoryFiles/meta_Electronics.json.gz

curl -L -O -C - http://snap.stanford.edu/data/amazon/productGraph/categoryFiles/reviews_Electronics.json.gz

unzip both the files as below,

gunzip meta_Electronics.json.gz

gunzip reviews_Electronics.json.gz

Copy the 2 files in to HDFS by creating the respective directories

hdfs dfs -copyFromLocal meta_Electronics.json /user/root/metadata

hdfs dfs -copyFromLocal reviews_Electronics.json /user/root/full_reviews

For the next step in Sentiment analysis Files in the Files directory are required to perform the scoring of the words
