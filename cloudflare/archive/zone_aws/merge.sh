#!/bin/bash

yq -M ea '. as $item ireduce ({}; . * $item)' dns/*.yaml
