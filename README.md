# RFID Hackaton SM
Projecte de Hackaton de Sistemes Multimèdia 2021-2022


## Description
Implementació d'un sistema de pagament i estadístic pel transport públic,
amb l'ús de targetes RFID i una aplicació mòvil pròpia que permet pagar i gestionar la conta de l'usauri.

La fita és eliminar el sistema actual de pagament del transport públic en l'Àrea Metropolitana de Barcelona que utilitza una targeta física de paper.

Es preveu també obtenir i tractar les dades dels usuaris per tal de gestionar la flota de manera òptima.

## Integrants del grup
<ul>
  <li>Martí Caixal (1563587)</li>
  <li>Bruno Moya (1568176)</li>
  <li>Marc Garrofé (1565644)</li>
  <li>Ricard Lopez (1571136)</li>
  <li>Hernán Capilla (1462773)</li>
</ul>

## Ficant en marxa

Tenim el projecte separat en aquestes carpetes:

- `rfid_hackaton` 
  -  Projecte de flutter (el frontend) que es pot carregar i fer funcionar simplement clicant en el botó verd de Play.
- `python`
  -  Scripts de python que fan la simulació de busos i actualitzen les estadistiques dels usuaris.
  -  `python random_buses_feed.py` per començar la simulació de busos.
  -  `python update-db.py` quan es vulgui actualitzar les estadistiques de cada usuari. Aquest script va 1 per 1 per tots els usuaris existents.
- `database`
  - Exportació del firebase

-  `esp32/nfc_esp32` 
    - Codi del esp32, sistema de arduino amb wifi integrat. Aquest es pot obrir amb el arduino ide i flashejar en el arduino.

- `slides`
  - Diapositives de la presentació del projecte   

## Resultat del Projecte

https://user-images.githubusercontent.com/10481058/170676233-9372d9c0-6dd5-49e7-a45e-7e774ffa87ae.mp4


### Com ha anat avançant el projecte?

Es pot veure en aquests videos com ha anat millorant el projecte fins arribar al final d'aquest.


<div>
<table>
  <tr>
    <th>Data</th>
    <th>Video</th>
  </tr>
  <tr>
    <td>02/05/2022</td>
    <td>
      https://user-images.githubusercontent.com/10481058/166267477-9b73c829-43bf-424a-98ea-c65133a61608.mp4
    </td>
  </tr>
  <tr>
    <td>14/05/2022</td>
    <td>https://user-images.githubusercontent.com/10481058/168439860-c9f9bafa-7f5b-4ea8-8d60-8ac99521c00c.mp4</td>
  </tr>
  <tr>
    <td>27/05/2022</td>
    <td>https://user-images.githubusercontent.com/10481058/170676233-9372d9c0-6dd5-49e7-a45e-7e774ffa87ae.mp4</td>
  </tr>
</table>
</div>

## Tech Stack

**Client:** Flutter amb distintes apis per mostrar el mapa

**Server:** Firebase, python


# License
MIT License

