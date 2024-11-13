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

print(sampleOrganization().display())

