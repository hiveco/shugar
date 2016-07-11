#!/bin/bash

import()
{
	echo eval "source <(curl -s https://raw.githubusercontent.com/hiveco/shugar/master/$1.sh)"
}
