//
//  PokemonDetailsMapper.swift
//  PokemonBoostIt
//
//  Created by Andrii Kvashuk on 13/05/2024.
//

import Foundation

struct PokemonDetailsMapper {
    static func map(data: Data) throws -> PokemonDetails {
        let mapped = try JSONDecoder().decode(RemotePokemonDetails.self, from: data)
        
        return PokemonDetails(abilities: mapped.abilities,
                              forms: mapped.forms,
                              baseExperience: mapped.baseExperience,
                              cries: mapped.cries,
                              order: mapped.order,
                              weight: mapped.weight)
    }
}
