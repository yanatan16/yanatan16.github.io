---
title: Anatomy of a Data Pipeline
layout: post
section: programming
date: 2019-12-04 12:00:00
---

Data Pipelines are big and complex things. There are many technologies to choose from. They must scale to enormous levels. So how should we organize the construction of these pipelines? Should we ETL (Extract-Transform-Load aka _modify data_) data in motion (i.e. in stream) or at rest (i.e. from a data lake or warehouse in batch jobs). How should we authenticate data sources? How should we handle source aggregation (i.e. aggregation that happens before pipeline ingestion). How can we handle sampling and routing of messages?

---

First of all, a definition: A Data Pipeline is an internal streaming data system to ingest, parse, enrich, process, and store data for later querying from external sources.