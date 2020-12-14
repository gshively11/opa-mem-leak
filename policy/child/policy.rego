package example.child.resource

import data.example.global

default authz = false

authz {
	global.high_risk
	global.http_send_call
}

default obligations = set()

obligations = o {
	o := global.high_risk_o
}
