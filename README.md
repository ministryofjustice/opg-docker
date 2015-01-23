# opg-docker


Q&A
---

Why does every service creates /var/log structure at runtime?

I't quite common that developer will run the container and mount /var/log
So make sure that every service started will pre-create its log directory structure on start time.
Instead of relying on RUN directives to do so.

