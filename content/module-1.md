page
Module 1 - Hardware Selection and Assembly


---

# Module 1 - 

## Objective
Selecting the appropriate hardware to fit your requirements and budget
<!-- if chatgpt isn't allowed: Chosing the right hardware for your needs and budget -->

## TLDR
Depending on your needs and budget, we provide a Bill of Materials for a number of 'stock' Builds [Here: BOM](place.holder)
<!-- TODO: provide BOM and replace placeholder link -->

## Board Selection
All 64bit RaspberryPi models are supported by this project, we provide working SD card images for the models we are able to test:
<!-- TODO: rephrase this intro -->

Boards:
- Tested:
    - Pi 5
    - Pi 4 (4GB)
- Supported:
    - Pi 4 (all models)
    - Pi 3B+
    - CM4
    - CM5
- Unsupported
    - Pi 1
    - Pi 2(A/B)
    - Pi 3(A)

#### A note on quantity:
Since this is a cluster, it's designed to be laterally scalable. you can use any number of Pi's you like. The recommened Node Enclosures stack nicely on a desk 3-4x high. 

## Storage selection
Storage is the most flexible part of this system. Only the head node *NEEDS* storage, this project will show you how to Net-Boot the compute and storage nodes using warewulf. Compute Nodes can be given an SD card or SSD to be used as local scratch or a distributed filesystem. For a budget oriented build, only a single, moderately sized (32GB), is needed for the head node. 

## Enclosures
We recommend one, single 4-node Pi enclosure for the Compute Nodes, it's compact, can be transported easily, and is stacked well. 
The head 


## Module 2 - Operating System Installation
