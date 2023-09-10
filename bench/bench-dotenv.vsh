#!/usr/bin/env -S v -prod run

import benchmark { start }
import dotenv as tdotenv
// import theboringdude.venv
import zztkm.vdotenv
import prantlf.dotenv

const repeat_count = 10_000

mut b := start()

for _ in 0 .. repeat_count {
	tdotenv.load()
}
b.measure('thomaspeissl.dotenv')

// for _ in 0 .. repeat_count {
// 	venv.load_env()
// }
// b.measure('theboringdude.venv')

for _ in 0 .. repeat_count {
	vdotenv.load()
}
b.measure('zztkm.vdotenv')

for _ in 0 .. repeat_count {
	dotenv.load_env()!
}
b.measure('prantlf.dotenv')
