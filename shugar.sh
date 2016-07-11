#!/bin/bash

import()
{
	echo eval "source <(curl -sL https://raw.github.com/hiveco/shugar/master/$1.sh)"
}
