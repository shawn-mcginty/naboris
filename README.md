# Naboris
Simple, fast, minimalist web framework for [OCaml](https://ocaml.org)/[ReasonML](https://reasonml.github.io) built on [httpaf](https://github.com/inhabitedtype/httpaf) and [lwt](https://github.com/ocsigen/lwt).

[![Build Status](https://travis-ci.com/shawn-mcginty/naboris.svg?branch=master)](https://travis-ci.com/shawn-mcginty/naboris)
[![opam version 0.0.7](https://img.shields.io/static/v1?label=opam&message=0.0.7&color=E7C162)](https://opam.ocaml.org/packages/naboris/)

```ocaml
let serverConfig: Naboris.ServerConfig.t(unit) = Naboris.ServerConfig.create()
  |> Naboris.ServerConfig.setRequestHandler((route, req, res) => switch(route.path) {
    | ["hello"] =>
      res
        |> Naboris.Res.status(200)
        |> Naboris.Res.text(req, "Hello world!");
      Lwt.return_unit;
    | _ =>
      res
        |> Naboris.Res.status(404)
        |> Naboris.Res.text(req, "Resource not found.");
      Lwt.return_unit;
  });

Naboris.listenAndWaitForever(3000, serverConfig);
// In a browser navigate to http://localhost:3000/hello
```

## Contents
* [Getting Started](#getting-started)
    * [Installation](#installation)
    * [Server Config](#server-config)
    * [Routing](#routing)
    * [Session Data](#session-data)
* [Advanced](#advanced)
	* [Middlewares](#middlewares)
* [Development](#development)

```
                                                           
 @@@@@  @@@@  @@@@@                                        
 *@*   @@@@@@   @@&                                        
  @@&  .@@@@  @@@/        @@,         (@@@                 
    ,    @@             @@@@@@@      @@@@@@@               
                       @@@@@@@@,    @@@@@@@@@              
        @@@*           @@@@@@@@@@@@@@@@@@@@@@              
       &@@@@          @@@@@@@@@@@@@.      &@@              
    @@@@@@@@           @@@@@@@@@@@@@@#(%(                  
    @@@@@  @@         .@@@@@@@@@@@@@@@@@@@@@*              
       ,@#  @*       @@@@@@@@@@@@@@@@@@@@@@@@@             
     # ,@@   @@     ,@@@@@@@@@@@@@@@@@@@@@@@@@@            
    .@@@@@.  .@@@   @@@@@@@@@@@@@@@@@@@@@@@@@@@@           
         @@.   @@@@ %@@@@@@@@@@@@@@@@@@@@@@@@@@@&          
         &@@*       .@@@.@@@@@@@@@@@*     (@@@@@@@@@@@@@@  
       @@@@@@@       @   @@@@@@@@@@   %@&   @@@@@@@@@@@*   
        @@  @@@@@      .@@@@@@@@ @  /@@@@@@     #@@@@@     
             @@@@@@    @@@@@@@@@    @@@@@@@@       @       
            @@@   %@   @@  , .@@   %@@(@&,@@%              
              ,          @@@@*       @@@@@                 
                         @@@@@        @@@@                 
                         @@@@@        @@@.                 
                         @@@@@        @@@%                 
                         @@@@@        @@@                  
                          %@           @.                  
                          (@           @                   
                          .%           ,                   
                                                           
                          @@(          @@                  
```

## Getting Started

### Installation

### Server Config

### Routing

### Session Data

## Advanced

### Middlewares

## Development
Any help would be greatly appreciated! 👍

### To run tests

```bash
esy install
npm run test
```