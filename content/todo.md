# Picluster To-Do

## Iron Out Image Creation Script
Done:
- headnode.sh
    - sets up networking, grabs packages, etc.
- warewulf.sh
    - builds and installs warewulf as well as dependencies
- ww-nodes.sh
    - builds compute node container
    - imports into ww
    - sets up node and profile definitions
    - bootstraps ww services

1. Run head-node creation script
2. validate
3. make fixes
4. goto step1

## Documentation:
Write:
- Hardware Selection
- accounting (tess?)
- analytics
- parallel programming
- benchmarking (HPL, LLM?)
- profiling
- basics of optimization

Edit:

Possible Additions:
- spack ???

Done:
- instructors
- nfs shares (warewulf changes)
- os installation
- timeserver (warewulf)
- warewulf (remove installation)
- slurm (ww node install)