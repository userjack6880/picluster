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
- Hardware Selection (john)
- parallel programming (matt?)

Research needed:
- Analytics
- maybe these should be combined:
    - profiling
    - Basics of optimization

Postponed:
- spack ???
- accounting (tess?)
- benchmarking (HPL, LLM?)

Done:
- instructors (almost entire rewrite updating hardware, install process, and references)
- nfs shares (warewulf changes)
- os installation (bootload flashing and head-node image)
- timeserver (warewulf)
- warewulf (remove installation)
- slurm (ww node install)
- supporting software (update to build openmpi)

## Proofreading:
All Modules need to be worked through by someone w/ enough experience to test but not ignore the docs. 

Untested:
- instructors
- nfs shares
- os installation
- timeserver
- warewulf
- slurm
- supporting software
- Analytics
- profiling
- Basics of optimization
- Hardware Selection
- parallel programming

Needs Revision:

Done: