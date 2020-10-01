type 'sessionData t = { id : string; data : 'sessionData }

let make id data = { id; data }

let data session = session.data

let id session = session.id
