#!/usr/bin/env python3
import base64

with open("./example_files/example.zip", "rb") as f:
    b64 = base64.urlsafe_b64encode(f.read())
    with open("./example_files/zipencode.txt", "wb") as fp:
        fp.write(b64)

