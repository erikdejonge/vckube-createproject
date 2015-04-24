# coding=utf-8
"""
cryptobox_provisioning
-
Active8 (12-03-15)
author: erik@a8.nl
license: GNU-GPL2
"""

import os
from os import path

import json
import requests


def main():
    """
    main
    """
    geoip = json.loads(requests.get("http://www.telize.com/geoip").text)
    configlocation1 = geoip["isp"] == "Routit BV"
    if configlocation1 is True:
        if path.exists("./configscripts/setconfiglocation1.sh") is True:
            os.system("./configscripts/setconfiglocation1.sh")
    else:
        if path.exists("./configscripts/setconfiglocation2.sh") is True:
            os.system("./configscripts/setconfiglocation2.sh")


if __name__ == "__main__":
    main()
