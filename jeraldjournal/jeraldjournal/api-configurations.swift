//
//  api-configurations.swift
//  jeraldjournal
//
//  Created by Zane Sabbagh on 11/14/23.
//

import Foundation
import OpenAI

let config = OpenAI.Configuration(token: "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", organizationIdentifier: "org-eLi8lax12wDHqF4H2gc5qCkV")
let openAI = OpenAI(configuration: config)
