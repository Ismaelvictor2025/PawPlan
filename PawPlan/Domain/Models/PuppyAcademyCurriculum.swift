//
//  PuppyAcademyCurriculum.swift
//  PawPlan
//
//  Created for PawPlan Puppy Academy.
//

import Foundation

public enum PuppyAcademyCurriculum {
    public static let modules: [TrainingModule] = [
        TrainingModule(
            id: "toilet_training",
            title: "Toilet Training & Housebreaking",
            category: "Essential Foundations",
            summary: "Proven positive reinforcement schedule for toilet training without anxiety or punishment.",
            iconName: "drop.fill",
            colorHex: "#15D9D2",
            milestones: [
                TrainingMilestone(
                    id: "tt_1",
                    title: "Recognising Pre-Toilet Signals",
                    summary: "Spot sniffing circles, pacing, sudden restlessness, or door hovering.",
                    tip: "Take your puppy out immediately after waking, eating, drinking, or vigorous play."
                ),
                TrainingMilestone(
                    id: "tt_2",
                    title: "Designated Spot Association",
                    summary: "Take your dog to the exact same grass patch on leash every single time.",
                    tip: "Say a calm cue like 'Go potty' and reward with high-value treats within 2 seconds of finishing."
                ),
                TrainingMilestone(
                    id: "tt_3",
                    title: "Night Routine & Bladder Endurance",
                    summary: "Establish overnight sleeping routines with last water 2 hours before bed.",
                    tip: "Puppy bladder rule of thumb: Age in months plus 1 hour is their daytime holding maximum."
                ),
                TrainingMilestone(
                    id: "tt_4",
                    title: "Accident Neutralisation Protocol",
                    summary: "Never punish past accidents. Use enzymatic cleaners to remove all scent traces.",
                    tip: "Punishing accidents creates secretive toileting behind sofas. Stay calm and praise outdoor success."
                )
            ]
        ),
        TrainingModule(
            id: "leash_manners",
            title: "Leash Manners & Loose Leash",
            category: "Public Etiquette",
            summary: "Teach your dog that walking beside you on a loose leash is the fastest way forward.",
            iconName: "figure.walk",
            colorHex: "#125BCE",
            milestones: [
                TrainingMilestone(
                    id: "lm_1",
                    title: "Indoor Harness Familiarisation",
                    summary: "Introduce Y-shaped harness and 1.8m flat lead indoors with treats.",
                    tip: "Avoid extendable/flexi leads during early training, which teach dogs that pulling extends freedom."
                ),
                TrainingMilestone(
                    id: "lm_2",
                    title: "The 'Tree' Technique",
                    summary: "Whenever the leash goes taut, freeze into a stationary tree immediately.",
                    tip: "The instant your dog looks back or creates slack, mark 'Yes!' and resume forward motion."
                ),
                TrainingMilestone(
                    id: "lm_3",
                    title: "J-Shape Leash Walking",
                    summary: "Maintain a gentle curved slack in the leash while walking in quiet areas.",
                    tip: "Deliver treats at your knee seam on your preferred walking side to establish the reward zone."
                ),
                TrainingMilestone(
                    id: "lm_4",
                    title: "Distraction Passings in Public",
                    summary: "Pass people, birds, and other dogs calmly on Sydney footpaths.",
                    tip: "Use the 'Find it' cue (scattering treats in grass) to redirect focus away from triggers."
                )
            ]
        ),
        TrainingModule(
            id: "basic_commands",
            title: "Core Obedience & Safety Commands",
            category: "Safety Essentials",
            summary: "Master Sit, Down, Stay, and the life-saving Emergency Recall ('Come').",
            iconName: "rosette",
            colorHex: "#FF7B00",
            milestones: [
                TrainingMilestone(
                    id: "bc_1",
                    title: "Reliable Sit & Down",
                    summary: "Lure into position with a treat above nose for sit, and between front paws for down.",
                    tip: "Fade the food lure quickly to a hand signal within 10 repetitions to avoid bribing."
                ),
                TrainingMilestone(
                    id: "bc_2",
                    title: "Impulse Control — 'Wait' at Doors",
                    summary: "Require sitting and eye contact before opening front doors or street gates.",
                    tip: "This simple milestone prevents dangerous doorway bolting onto busy roads."
                ),
                TrainingMilestone(
                    id: "bc_3",
                    title: "The Rocket Recall ('Come Here!')",
                    summary: "Build an unshakeable recall where coming back is always rewarded enthusiastically.",
                    tip: "Never call your dog to you to do something unpleasant (baths, nail clipping, leaving the park)."
                ),
                TrainingMilestone(
                    id: "bc_4",
                    title: "'Drop It' & 'Leave It'",
                    summary: "Trade dropped items for a higher-value treat to avoid resource guarding.",
                    tip: "Crucial in Australia for preventing ingestion of toxic plants, baits, or discarded chicken bones."
                )
            ]
        ),
        TrainingModule(
            id: "socialisation",
            title: "Socialisation & Sydney Awareness",
            category: "Puppy Psychology",
            summary: "Positive exposure to Sydney traffic, sounds, surfaces, dogs, and veterinary handling.",
            iconName: "sparkles",
            colorHex: "#9D4EDD",
            milestones: [
                TrainingMilestone(
                    id: "soc_1",
                    title: "Sound Desensitisation",
                    summary: "Low-volume exposure to thunderstorms, fireworks, sirens, and traffic noises.",
                    tip: "Play ambient sound effects during feeding time so sounds become associated with positive meals."
                ),
                TrainingMilestone(
                    id: "soc_2",
                    title: "Tactile Surface Exploration",
                    summary: "Walking comfortably on wet grass, sand, metal grates, wooden decking, and linoleum.",
                    tip: "Scatter treats on novel surfaces and allow the puppy to explore at their own pace."
                ),
                TrainingMilestone(
                    id: "soc_3",
                    title: "Gentle Vet & Grooming Handling",
                    summary: "Cooperative touch of paws, ears, teeth, and tail paired with lick mats.",
                    tip: "Preparation for future claw clipping, ear cleaning, and routine veterinary examinations."
                ),
                TrainingMilestone(
                    id: "soc_4",
                    title: "Neutral Dog Socialisation",
                    summary: "Teaching your dog that not every dog needs to be greeted on the street.",
                    tip: "Calm indifference to other dogs on footpaths is vastly superior to hyper-excited reactivity."
                )
            ]
        ),
        TrainingModule(
            id: "separation_confidence",
            title: "Crate Training & Home Alone Confidence",
            category: "Emotional Well-being",
            summary: "Prevent separation anxiety by building self-soothing comfort and independence.",
            iconName: "house.fill",
            colorHex: "#FF2A85",
            milestones: [
                TrainingMilestone(
                    id: "sep_1",
                    title: "The Crate / Playpen Sanctuary",
                    summary: "Transform the crate into a safe den with comfy bedding and chew toys.",
                    tip: "Never use the crate as a punishment timeout; it must always be an enjoyable, secure haven."
                ),
                TrainingMilestone(
                    id: "sep_2",
                    title: "Lick Mats & Long-Lasting Chews",
                    summary: "Provide frozen Kongs with wet food or peanut butter (xylitol-free).",
                    tip: "Licking and chewing releases calming endorphins that lower canine heart rate and cortisol."
                ),
                TrainingMilestone(
                    id: "sep_3",
                    title: "Micro-Departures Protocol",
                    summary: "Practise leaving the room for 30s, 2m, 5m, and 15m without dramatic goodbyes.",
                    tip: "Leave quietly and return calmly without over-excitement to normalise coming and going."
                ),
                TrainingMilestone(
                    id: "sep_4",
                    title: "2-Hour Confident Rest",
                    summary: "Puppy naps comfortably while owner is away running errands or working.",
                    tip: "A well-exercised puppy with a filled chew toy settles naturally during owner absences."
                )
            ]
        )
    ]
}

public struct NSWPetGuidanceItem: Identifiable, Sendable {
    public let id: String
    public let title: String
    public let summary: String
    public let authority: String
    public let keyRequirement: String
    public let iconName: String
}

public enum SydneyPetRegulationGuide {
    public static let guidance: [NSWPetGuidanceItem] = [
        NSWPetGuidanceItem(
            id: "microchip",
            title: "Mandatory Microchipping",
            summary: "Under the NSW Companion Animals Act 1998, all puppies must be microchipped before 12 weeks of age or before being sold or rehomed.",
            authority: "NSW Office of Local Government",
            keyRequirement: "Must be done by an authorised identifier (vet or licensed implanter). Always update address and phone if moving.",
            iconName: "antenna.radiowaves.left.and.right"
        ),
        NSWPetGuidanceItem(
            id: "registration",
            title: "Lifetime Council Registration",
            summary: "In NSW, all dogs must have a one-time lifetime registration on the NSW Pet Registry by 12 weeks of age.",
            authority: "Local Councils across NSW",
            keyRequirement: "Desexed dogs enjoy heavily discounted registration fees. Carries lifetime validity anywhere in NSW.",
            iconName: "tag.fill"
        ),
        NSWPetGuidanceItem(
            id: "leash_rules",
            title: "NSW Public Leash Regulations",
            summary: "Dogs must be kept on a leash at all times in any public place across NSW, unless in a clearly designated off-leash park.",
            authority: "Section 13, Companion Animals Act 1998",
            keyRequirement: "Leash must be held continuously by a person competent to restrain the dog. Fines exceed $330 for off-leash breaches.",
            iconName: "figure.walk"
        ),
        NSWPetGuidanceItem(
            id: "paralysis_ticks",
            title: "Paralysis Tick Season Awareness",
            summary: "Eastern Australian paralysis ticks (Ixodes holocyclus) are common in Sydney bushland, northern beaches, and leafy parks from spring through autumn.",
            authority: "Australian Veterinary Association (AVA)",
            keyRequirement: "Administer veterinary-approved chewables (e.g. isoxazoline class). Check daily from head to paws, especially behind ears and lips.",
            iconName: "cross.fill"
        ),
        NSWPetGuidanceItem(
            id: "heat_safety",
            title: "Sydney Summer Heat & Pavement Safety",
            summary: "Hot bitumen and humid Sydney days can rapidly cause thermal burns to paw pads and deadly heatstroke in dogs.",
            authority: "RSPCA NSW Heat Safety Advisory",
            keyRequirement: "The 7-second rule: Place the back of your hand on the asphalt for 7 seconds. If it hurts you, it burns your dog's paws. Walk before 8am or after 6pm.",
            iconName: "sun.max.fill"
        ),
        NSWPetGuidanceItem(
            id: "cleaning_waste",
            title: "Dog Waste Removal Law",
            summary: "Failing to pick up and dispose of dog faeces in public places attracts on-the-spot council infringement notices.",
            authority: "NSW Companion Animals Act 1998",
            keyRequirement: "Always carry compostable waste bags. Many Sydney parks provide dedicated dispenser bins.",
            iconName: "trash.fill"
        )
    ]
}
