package example.global

default jwt_exists = false

jwt_exists {
	input.jwt
	trace("jwt exists")
}

default jwt_exists_o = set()

jwt_exists_o = o {
	not jwt_exists
	o := {"LOGIN"}
	trace("jwt does not exist")
}

jwt = t {
	[_, payload, _] = io.jwt.decode(input.jwt)
	t := {"payload": payload}
	trace("jwt decoded")
}

default jwt_typ_is_jwt = false

jwt_typ_is_jwt {
	jwt.payload.typ == "jwt"
	trace("jwt.typ is jwt")
}

default jwt_auth_is_blah = false

jwt_auth_is_blah {
	jwt.payload.auth == "blah"
	trace("jwt.auth is blah")
}

jwt_payload = e {
	jwt_auth_is_blah
	jwt_typ_is_jwt
	e := jwt.payload
}

jwt_factors[f] {
	some f
	jwt_payload.factors[f] > 0
}

default jwt_two_factors = false

jwt_two_factors {
	count(jwt_factors) >= 2
	trace("jwt has at least 2 auth factors")
}

default jwt_two_factors_o = set()

jwt_two_factors_o = o {
	not jwt_two_factors
	o := {"LOGIN_MFA"}
	trace("jwt has less than 2 auth factors")
}

default jwt_age_in_seconds = -1

jwt_age_in_seconds = iat {
	jwt.payload.iat
	iat := round(time.now_ns() / 1e9) - jwt.payload.iat
}

default jwt_is_less_than_180_days_old = false

jwt_is_less_than_180_days_old {
	jwt_age_in_seconds >= 0
	jwt_age_in_seconds < ((60 * 60) * 24) * 180
	trace("jwt age is less than 180 days")
}

default jwt_is_less_than_24_hours_old = false

jwt_is_less_than_24_hours_old {
	jwt_age_in_seconds >= 0
	jwt_age_in_seconds < (60 * 60) * 24
	trace("jwt age is less than 24 hours")
}

default low_risk = false

low_risk {
	jwt_exists
	jwt_is_less_than_180_days_old
	trace("jwt is valid for low risk operations")
}

default low_risk_o = set()

low_risk_o = o {
	not low_risk
	o := jwt_exists_o
	trace("jwt is not valid for low risk operations")
}

default high_risk = false

high_risk {
	jwt_exists
	jwt_is_less_than_180_days_old
	jwt_two_factors
	trace("jwt is valid for high risk operations")
}

default high_risk_o = set()

high_risk_o = o {
	not high_risk
	o := jwt_exists_o | jwt_two_factors_o
	trace("jwt is not valid for high risk operations")
}

http_send_call = r {
	response := http.send({
		"method": "GET",
		"url": sprintf("http://localhost:8888/some_data?%s", [input.cache_bust]),
		"enable_redirect": true,
		"timeout": "5s",
		"cache": true,
	})

	response.status_code == 200
	r := response.raw_body
}
