type 'sessionData t = {
  id : string;
  data : 'sessionData;
}

let create id data = {
  id; data;
}

let data sessionData = sessionData.data

let id sessionData = sessionData.id 