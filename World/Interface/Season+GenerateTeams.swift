//
//  Season+GenerateTeams.swift
//  World
//
//  Created by Shyam Kumar on 7/4/23.
//

import Foundation

extension Season {
    static func generateTeams() -> [Team] {
        return [
            .init(
                teamName: "Arizona",
                teamAbbreviation: "AZ",
                teamColorPrimary: "#A71930",
                teamColorSecondary: "#000000",
                league: .national,
                division: .west
            ),
            .init(
                teamName: "Atlanta",
                teamAbbreviation: "ATL",
                teamColorPrimary: "#CE1141",
                teamColorSecondary: "#13274F",
                league: .national,
                division: .east
            ),
            .init(
                teamName: "Baltimore",
                teamAbbreviation: "BAL",
                teamColorPrimary: "#DF4601",
                teamColorSecondary: "#000000",
                league: .american,
                division: .east
            ),
            .init(
                teamName: "Boston",
                teamAbbreviation: "BOS",
                teamColorPrimary: "#BD3039",
                teamColorSecondary: "#0C2340",
                league: .american,
                division: .east
            ),
            .init(
                teamName: "Chicago",
                teamAbbreviation: "CHI",
                teamColorPrimary: "#0E3386",
                teamColorSecondary: "#CC3433",
                league: .national,
                division: .central
            ),
            .init(
                teamName: "New Orleans",
                teamAbbreviation: "NOR",
                teamColorPrimary: "#27251F",
                teamColorSecondary: "#C4CED4",
                league: .american,
                division: .central
            ),
            .init(
                teamName: "Cincinnati",
                teamAbbreviation: "CIN",
                teamColorPrimary: "#C6011F",
                teamColorSecondary: "#000000",
                league: .national,
                division: .central
            ),
            .init(
                teamName: "Cleveland",
                teamAbbreviation: "CLE",
                teamColorPrimary: "#00385D",
                teamColorSecondary: "#E50022",
                league: .american,
                division: .central
            ),
            .init(
                teamName: "Colorado",
                teamAbbreviation: "COL",
                teamColorPrimary: "#333366",
                teamColorSecondary: "#131413",
                league: .national,
                division: .west
            ),
            .init(
                teamName: "Detroit",
                teamAbbreviation: "DET",
                teamColorPrimary: "#0C2340",
                teamColorSecondary: "#FA4616",
                league: .american,
                division: .central
            ),
            .init(
                teamName: "Houston",
                teamAbbreviation: "HOU",
                teamColorPrimary: "#002D62",
                teamColorSecondary: "#EB6E1F",
                league: .american,
                division: .west
            ),
            .init(
                teamName: "Kansas City",
                teamAbbreviation: "KC",
                teamColorPrimary: "#004687",
                teamColorSecondary: "#004687",
                league: .american,
                division: .central
            ),
            .init(
                teamName: "Los Angeles",
                teamAbbreviation: "LA",
                teamColorPrimary: "#003263",
                teamColorSecondary: "#BA0021",
                league: .american,
                division: .west
            ),
            .init(
                teamName: "Las Vegas",
                teamAbbreviation: "LV",
                teamColorPrimary: "#005A9C",
                teamColorSecondary: "#EF3E42",
                league: .national,
                division: .west
            ),
            .init(
                teamName: "Miami",
                teamAbbreviation: "MIA",
                teamColorPrimary: "#00A3E0",
                teamColorSecondary: "#EF3340",
                league: .national,
                division: .east
            ),
            .init(
                teamName: "Milwaukee",
                teamAbbreviation: "MIL",
                teamColorPrimary: "#FFC52F",
                teamColorSecondary: "#12284B",
                league: .national,
                division: .central
            ),
            .init(
                teamName: "Minnesota",
                teamAbbreviation: "MIN",
                teamColorPrimary: "#002B5C",
                teamColorSecondary: "#D31145",
                league: .american,
                division: .central
            ),
            .init(
                teamName: "New York",
                teamAbbreviation: "NY",
                teamColorPrimary: "#002D72",
                teamColorSecondary: "#FF5910",
                league: .national,
                division: .east
            ),
            .init(
                teamName: "North Carolina",
                teamAbbreviation: "NC",
                teamColorPrimary: "#003087",
                teamColorSecondary: "#E4002C",
                league: .american,
                division: .east
            ),
            .init(
                teamName: "Oakland",
                teamAbbreviation: "OAK",
                teamColorPrimary: "#003831",
                teamColorSecondary: "#EFB21E",
                league: .american,
                division: .west
            ),
            .init(
                teamName: "Philadelphia",
                teamAbbreviation: "PHI",
                teamColorPrimary: "#E81828",
                teamColorSecondary: "#002D72",
                league: .national,
                division: .east
            ),
            .init(
                teamName: "Pittsburgh",
                teamAbbreviation: "PIT",
                teamColorPrimary: "#27251F",
                teamColorSecondary: "#FDB827",
                league: .national,
                division: .central
            ),
            .init(
                teamName: "Saint Louis",
                teamAbbreviation: "STL",
                teamColorPrimary: "#C41E3A",
                teamColorSecondary: "#0C2340",
                league: .national,
                division: .central
            ),
            .init(
                teamName: "San Diego",
                teamAbbreviation: "SD",
                teamColorPrimary: "#C41E3A",
                teamColorSecondary: "#FFC425",
                league: .national,
                division: .west
            ),
            .init(
                teamName: "San Francisco",
                teamAbbreviation: "SF",
                teamColorPrimary: "#FD5A1E",
                teamColorSecondary: "#27251F",
                league: .national,
                division: .west
            ),
            .init(
                teamName: "Seattle",
                teamAbbreviation: "SEA",
                teamColorPrimary: "#0C2C56",
                teamColorSecondary: "#005C5C",
                league: .american,
                division: .west
            ),
            .init(
                teamName: "Tampa Bay",
                teamAbbreviation: "TB",
                teamColorPrimary: "#092C5C",
                teamColorSecondary: "#8FBCE6",
                league: .american,
                division: .east
            ),
            .init(
                teamName: "Texas",
                teamAbbreviation: "TX",
                teamColorPrimary: "#003278",
                teamColorSecondary: "#C0111F",
                league: .american,
                division: .west
            ),
            .init(
                teamName: "Toronto",
                teamAbbreviation: "TOR",
                teamColorPrimary: "#134A8E",
                teamColorSecondary: "#1D2D5C",
                league: .american,
                division: .east
            ),
            .init(
                teamName: "Washington",
                teamAbbreviation: "WAS",
                teamColorPrimary: "#AB0003",
                teamColorSecondary: "#14225A",
                league: .national,
                division: .east
            )
        ]
    }
}
