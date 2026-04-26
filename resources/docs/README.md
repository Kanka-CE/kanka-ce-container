# Kanka Community Edition
*A community-maintained, self-hostable variant of the Kanka worldbuilding platform.*


## What is this?

**Kanka Community Edition (Kanka CE)** is a community-maintained fork of the official  
[Kanka](https://github.com/owlchester/kanka) worldbuilding platform.
It contains the **patched and transformed source code** of Kanka to make selfhosting easier. 
To maintain compatibility with the original upstream Kanka codebase the [kanka-ce-tools](https://github.com/kinnewig/kanka-ce-tools) are used
to apply many changes automatically to each new release of Kanka.

Kanka CE is **not** affiliated with the official Kanka project.


## Quick Start Guide

- Install prequisits

- Download Kanka CE
```bash
git clone https://github.com/kinnewig/kanka-community-edition.git
```

- Configure Kanka CE
Create your own config for Kanka, you can use `.env.example` as a starting point
```bash
cp .env.example .env
```
and modify `.env`.

- Secure Kanka CE
To generate secure passwords run
```bash
./gen-passwords.sh
```

- In case you are running rootfull
```bash
chown -R 1000:1000 </PATH/TO/KANKA-CE/ROOT>
```

- Prepare the container
This is fully automated, just run the following command
```bash
./prepare-kanka-ce.sh
```

- Preview
You should now be able to preview Kanka-CE when you visit
```bash
http://localhost:8081
```
However, you should **not** publish that port to the internet. 
Instead you should configure a reverse proxy pointing to that port.

- Publish 
Once you are satisfied with your configuration and ensured everything is safe, you are ready to publish your very own Kanka-CE!
To do so, change in the .env:
```bash
APP_ENV=local
```
to 
```bash
APP_ENV=production
```


## Contributing

Kanka Community Edition can only exist if the community helps build it.

This project is entirely maintained by volunteers, people who love Kanka, want to self‑host it, and believe in open collaboration. Every improvement, every fix, every idea comes from people like you. Kanka CE is still in an early stage, so help is apprichiated very much!

No contribution is too small, even a typo fix helps move the project forward.

If you want Kanka CE to grow, stay compatible, and remain self‑hostable,  
**please consider contributing. The Community Edition lives through its community.**


## ❤️ Support the Official Kanka Project
Kanka CE exists because the upstream project is amazing.
If you enjoy using Kanka or Kanka CE, please consider supporting the original creators:

💙 **Kanka Website:** https://kanka.io  

## License

This repository contains a modified version of the official Kanka source code, which is licensed under *Commons Clause License Condition v1.0*

- You may not remove or alter the Commons Clause.
- You may not sell this software or offer it as a paid service.
- See the included LICENSE file for full details.


## Notice
This repository contains modifications made by the community.
All original work is © the Kanka authors.


