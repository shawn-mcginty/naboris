## Getting Started

### Configure the server
```reasonml
let serverConfig: Naboris.Server.serverConfig = {
  onListen: () => {
    print_string("Yay your server has started!!\n\n");
  },
  routes: [
    {
      method: GET,
      path: "/html",
      requestHandler: (req, res) => {
        Naboris.Res.status(200, res)
        |> Naboris.Res.html(
             req,
             "<!doctype html><html><body>You made it.</body></html>",
           );
      },
    }
  ],
};
```

- `onListen` - Function callback that fires after the server has started.
- `routes` - A list of records which define the routes your server will handle and how to handle them.

### Fire it up!

```reasonml
let portNumber = 9991;

Naboris.listen(portNumber, serverConfig);
```