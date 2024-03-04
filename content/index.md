page
index


---

# Pi HPC Introduction

<span class="small">Last Update 23 October 2023</span>

These modules are intended on teaching you how to configure, setup, and run your own miniature cluster computer. While there are some differences between our setup and supercomputers on the Top500, the fundementals are essentially the same - a bunch of Linux computers performing various functions of an entire system.

The instructions provided are assuming that you have the following hardware:

- 5+ Raspberry Pi 4B with extra SSD storage (up to 41)
  - 120GB minimum recommended
  - 1 board will be used for the head and login node, the rest are for storage
- 4+ Raspberry Pi 4B (up to 40)
  - These will be used for compute
- 1 Raspberry Pi Zero W/Zero 2 W (Optional)
  - Optional node - this will not have HPC-related software on it, it is simply a terminal for students to use to SSH into the rest of the cluster.
- Network Switch
  - This will not need to be connected to the internet to go through the modules, but instructors will need network access for initial setup.

[Instructors: Read This First](instructors)

# Modules

- [Module 1 - Sharing Storage](module-1)
- [Module 2 - Keeping Time](module-2)
- [Module 3 - Setup Scheduler](module-3)
- [Module 4 - Supporting Software](module-4)
- [Module 5 - Hello Worlds](module-5)
- Module 6 - Parallel Storage