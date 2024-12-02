//-*- coding: utf-8 -*-
/**
  main.swift: Entry point to the org program. Prints a sample org chart.
*/
/* -------------------------------------------------------------------
 * main.swift: Entry point to the org program. Prints a sample org chart.
 *
 * Copyright (C) 2024 Sumanth Vepa.
 *
 * This program is free software: you can redistribute it and/or
 * modify it under the terms of the GNU General Public License a
 * published by the Free Software Foundation, either version 3 of the
 * License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see
 * <https://www.gnu.org/licenses/>.
 *-----------------------------------------------------------------*/

/**
 Create a sample organization to showcase org chart printing
 
 - returns: A manager object representing the leader of the organization.
*/
func sampleOrganization() -> Manager {
  let arjun = IndividualContributor(name: "Arjun Acemoglu")
  let konrad = IndividualContributor(name: "Konrad Kraikupt")
  let mandy = IndividualContributor(name: "Mandy Maalouf")
  let lars = Manager(name: "Lars Littlebear", subordinates: [mandy])
  let betty = Manager(name: "Betty Bian", subordinates: [konrad, lars])
  let ciara = IndividualContributor(name: "Ciara Chukwu")
  let dian = IndividualContributor(name: "Dian Dagar")
  let emmet = IndividualContributor(name: "Emmet Ergasi")
  let faisal = IndividualContributor(name: "Faisal Fabbiani")
  let olga = IndividualContributor(name: "Olga Omarosa")
  let petter = IndividualContributor(name: "Petter Palanisamy")
  let qian = IndividualContributor(name: "Qian Quasimodo")
  let niara = Manager(name: "Niara Naber", subordinates: [olga, petter, qian])
  let girish = Manager(name: "Girish Gadjinsky", subordinates: [arjun, betty, niara])
  let harald = Manager(name: "Harald Heß", subordinates: [ciara, dian, emmet])
  let joko = Manager(name: "Joko Jokic", subordinates: [faisal, girish, harald])
  return joko
}

func sampleOrganization2() -> Manager {
  return Manager(name: "Joko Jokic", subordinates: makeOrg {
    IndividualContributor(name: "Faisal Fabiani")
    Manager(name: "Girish Gadjinsky", subordinates: makeOrg {
      IndividualContributor(name: "Arjun Acemoglu")
      Manager(name: "Betty Bian", subordinates: makeOrg {
        IndividualContributor(name:"Konrad Kraikupt")
        Manager(name: "Lars Littlebear", subordinates: makeOrg {
          IndividualContributor(name: "Mandy Maalouf")
        })
      })
      Manager(name: "Niara Naber", subordinates: makeOrg {
        IndividualContributor(name: "Olga Omarosa")
        IndividualContributor(name: "Petter Palanisamy")
        IndividualContributor(name: "Qian Quasimodo")
      })
    })
    Manager(name: "Harald Heß", subordinates: makeOrg {
      IndividualContributor(name: "Ciara Chukwu")
      IndividualContributor(name: "Dian Dagar")
      IndividualContributor(name: "Emmet Ergasi")
    })
  })
}

print(sampleOrganization().display())
print(sampleOrganization2().display())

