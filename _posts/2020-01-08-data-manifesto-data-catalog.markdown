---
title: Why You Need a Data Catalog
layout: post
categories: programming
date: 2020-01-08 12:00:00
manifesto: data
---

Have you ever been in a situation where you're looking into a dataset for the first time? It usually goes something like this:

- You infer a data model from some inspection of a single datum, or a few data.
- You start by assuming that data model holds for everything in the dataset. So you query the dataset using that model as an assumption.
- This inevitably fails due to lack of handling for message types, extra fields, union fields, etc.
- So you start the process of exhaustively searching for all the various possible data models a single datum can exhibit. This takes a while.
- Finally, you have a complete data model. Now you query you're dataset for your desired question. But, some of the data is bad and you find errors in your output.
- Now you have to figure out how to account for data errors that show up seemingly randomly in the data.
- After all this, you finally can run your query.
- Then you find out that someone you know already did all this and wrote some code to handle it and didn't write it down in documentation. ARGH!

Have you ever thought there might be a better way? So have a lot of people. Thats why **Data Catalogs** exist.

<!--break-->

*Definition*: At a minimum, a **Data Catalog** is a searchable database of your data's metadata with a human-friendly UI.

The goal of a Data Catalog is to distribute *knowledge* (from humans or from programs) about your data across your organization so that no one has to endure the pain described above more than once (ideally never). It accomplishes this through a few mechanisms:

- **Database Independence**: It stores metadata for datasets from multiple databases, allowing users to not have to remember where data is stored to get quick access to it.
- **Searchability**: It allows searching of all metadata regardless of storage location, allowing users to find their needs quicker and with less a priori knowledge.
- **Lineage**: It tracks the lineage of data, that is, the directed acyclic graph (DAG) of how data is extracted, transformed, and loaded (ETL) into downstream data. This enhances users' ability to track down issues, and understand how data came to be.
- **Annotation**: It allows annotation of data by its users so that they can share relevant knowledge about the data with each other in a targeted and secure manner.

Let's go back to the example above and see how you would start looking into a new dataset in a world with a Data Catalog:

- You first search the Data Catalog for this dataset's name (table name, kafka topic, etc)
- Upon finding the page for this dataset, you see its data model in full and its lineage.
- In the annotations of this dataset, you see notes from other analysts who suggest methods for handling the bad data points.
- Looking closer at the lineage though, you see that this dataset has been ETL'd into a downstream dataset that is called "clean."
- You run a query on the clean dataset and it works.

Now isn't that easier? Of course that isn't the story every time, but the efficiency savings are real.

Some people might raise a question that: *Isn't a schema browser a sufficient data catalog?* The answer is no. A schema browser isn't easily searchable (exceptions exist), isn't database independent, doesn't track lineage, and doesn't allow annotation. It doesn't convey anything other than a data model (and not a very good one either).

Now you ask, *what's the cost?* Well, you can get [Apache Atlas](https://atlas.apache.org) for free. It works quite well as a baseline system. It will take an engineer a small amount of time to setup and start loading metadata into. Then you must add lineage metadata loading by updating your ETL frameworks (both batch and ETL). For organizations of any reasonably "big" size, this cost is orders of magnitude less than the efficiency gain received by engineers and analysts working with the data.
