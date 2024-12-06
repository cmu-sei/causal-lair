#!/usr/bin/env bash

IP=$(ip route get 1 | awk '{print $7}')

quarto preview /app/AIRTool_v2.2.qmd --port 4173 --host $IP

