const yoyoNftCollection: NftMetadata[] = [

    // 1. Seated Symphony
    {
        name: "Seated Symphony: Adaptive Chair Yoga",
        description: "Developed with physiotherapists for wheelchair users. Focus on spinal mobility and chest opening without load on the lower limbs.",
        image: "ipfs://QmYy1...wheelchair_flow",
        attributes: [
            { trait_type: "Support", value: "Wheelchair" },
            { trait_type: "Medical Focus", value: "Posture and Breathing" },
            { trait_type: "Duration", value: "25 min" }
        ],
        properties: {
            category: "Adaptive Yoga",
            course_type: "Physio-Flow",
            accessibility_level: "High Mobility Support",
            redeemable: true,
            instructor_certified: true,
            style: "Inclusive"
        }
    },

    // 2. Bionic Balance
    {
        name: "Bionic Balance: Yoga & Prosthetics",
        description: "A unique journey to integrate prosthetic use into practice, working on weight balance and proprioception.",
        image: "ipfs://QmYy2...prosthetic_balance",
        attributes: [
            { trait_type: "Focus", value: "Proprioception" },
            { trait_type: "Limb", value: "Upper/Lower" },
            { trait_type: "Difficulty", value: 2 }
        ],
        properties: {
            category: "Specialized Yoga",
            course_type: "Adaptive Hatha",
            accessibility_level: "Prosthetic Friendly",
            redeemable: true,
            instructor_certified: true,
            style: "Technical"
        }
    },

    // 3. Inclusive Maternity
    {
        name: "Inclusive Maternity: Prenatal Yoga",
        description: "Gentle practice supporting bodily changes, with specific variations for those with pre-existing mobility challenges.",
        image: "ipfs://QmYy3...sacred_bump",
        attributes: [
            { trait_type: "Trimester", value: "All" },
            { trait_type: "Chakra", value: "Svadhisthana" }
        ],
        properties: {
            category: "Wellness",
            course_type: "Prenatal Yoga",
            accessibility_level: "Pregnancy Safe",
            redeemable: false,
            instructor_certified: true,
            style: "Soft"
        }
    },

    // 4. Horizontal Horizon
    {
        name: "Horizontal Horizon: Bed-Based Yoga",
        description: "Ideal for extremely limited mobility or for those confined to bed. Micro-articular movements and guided myofascial release.",
        image: "ipfs://QmYy4...bed_yoga",
        attributes: [
            { trait_type: "Position", value: "Supine" },
            { trait_type: "Intensity", value: "Low" }
        ],
        properties: {
            category: "Adaptive Yoga",
            course_type: "Restorative",
            accessibility_level: "Bed-Bound Friendly",
            redeemable: false,
            instructor_certified: true,
            style: "Minimalist"
        }
    },

    // 5. YoYo Challenge
    {
        name: "YoYo Challenge: Collective Strength",
        description: "Live simultaneous challenge! An inclusive sequence where each asana has 3 variations (chair, floor, standing). Let's climb the leaderboard together.",
        image: "ipfs://QmYy5...community_challenge",
        attributes: [
            { trait_type: "Type", value: "Live Challenge" },
            { trait_type: "Community Points", value: 1000 }
        ],
        properties: {
            category: "Community",
            course_type: "Interactive Session",
            accessibility_level: "Universal Access",
            redeemable: false,
            instructor_certified: true,
            style: "Social"
        }
    },

    // 6. Breath Without Borders
    {
        name: "Breath Without Borders: Pranayama",
        description: "Breathing techniques to increase lung capacity, essential for those with physical movement limitations.",
        image: "ipfs://QmYy6...breath_work",
        attributes: [
            { trait_type: "Focus", value: "Nervous System" },
            { trait_type: "Element", value: "Air" }
        ],
        properties: {
            category: "Wellness",
            course_type: "Pranayama",
            accessibility_level: "All levels",
            redeemable: false,
            instructor_certified: true,
            style: "Mystical"
        }
    },

    // 7. Free Wrists
    {
        name: "Free Wrists: Hands-Free Flow",
        description: "A dynamic Vinyasa practice that never requires placing hands on the floor. Perfect for carpal tunnel or upper limb prosthetics.",
        image: "ipfs://QmYy7...hands_free",
        attributes: [
            { trait_type: "No-Go", value: "No wrist loading" },
            { trait_type: "Focus", value: "Legs and Core" }
        ],
        properties: {
            category: "Yoga",
            course_type: "Vinyasa Flow",
            accessibility_level: "Wrist-Injury Friendly",
            redeemable: false,
            instructor_certified: true,
            style: "Modern"
        }
    },

    // 8. Iron Core
    {
        name: "Iron Core (Physio-Yoga)",
        description: "Focus on trunk stability to support the spine and improve independence in daily movement.",
        image: "ipfs://QmYy8...core_stability",
        attributes: [
            { trait_type: "Medical Focus", value: "Spinal Stability" },
            { trait_type: "Intensity", value: 4 }
        ],
        properties: {
            category: "Performance",
            course_type: "Power Yoga",
            accessibility_level: "Intermediate",
            redeemable: true,
            instructor_certified: true,
            style: "Technical"
        }
    },

    // 9. The Sound of Silence
    {
        name: "The Sound of Silence: Yoga Nidra",
        description: "Deep meditation accessible to everyone. Requires no physical movement, only mindful listening.",
        image: "ipfs://QmYy9...yoga_nidra",
        attributes: [
            { trait_type: "Type", value: "Deep Relaxation" },
            { trait_type: "Duration", value: "40 min" }
        ],
        properties: {
            category: "Mindfulness",
            course_type: "Yoga Nidra",
            accessibility_level: "Universal Access",
            redeemable: false,
            instructor_certified: true,
            style: "Spiritual"
        }
    },

    // 10. Golden Joints
    {
        name: "Golden Joints: Senior Yoga",
        description: "A program dedicated to seniors with gentle movements to counter arthritis and improve joint flexibility.",
        image: "ipfs://QmYy10...senior_gold",
        attributes: [
            { trait_type: "Target", value: "Seniors" },
            { trait_type: "Focus", value: "Gentle Mobility" }
        ],
        properties: {
            category: "Wellness",
            course_type: "Hatha Yoga",
            accessibility_level: "Beginner",
            redeemable: false,
            instructor_certified: true,
            style: "Soft"
        }
    },

    // 11. Post-Surgery Recovery
    {
        name: "Post-Surgery Yoga: Recovery Flow",
        description: "Developed with surgeons and physiotherapists to restore mobility after surgery. Medical approval required.",
        image: "ipfs://QmYy11...recovery_flow",
        attributes: [
            { trait_type: "Phase", value: "Post-Rehabilitation" },
            { trait_type: "Risk", value: "Low" }
        ],
        properties: {
            category: "Medical Yoga",
            course_type: "Physio-Yoga",
            accessibility_level: "Post-Surgery Recovery",
            redeemable: true,
            instructor_certified: true,
            style: "Technical"
        }
    },

    // 12. Visual Balance
    {
        name: "Visual Balance: Yoga for the Blind",
        description: "A practice entirely based on precise audio guidance and spatial awareness, for those who experience yoga through touch and sound.",
        image: "ipfs://QmYy12...audio_yoga",
        attributes: [
            { trait_type: "Support", value: "8D Audio Guidance" },
            { trait_type: "Focus", value: "Proprioception" }
        ],
        properties: {
            category: "Specialized Yoga",
            course_type: "Guided Flow",
            accessibility_level: "Visually Impaired Friendly",
            redeemable: false,
            instructor_certified: true,
            style: "Inclusive"
        }
    },

    // 13. Chronic Pain Relief
    {
        name: "Chronic Pain: Mindful Yin",
        description: "Yin Yoga sessions using extensive blocks, bolsters and blankets for those suffering from fibromyalgia or chronic fatigue.",
        image: "ipfs://QmYy13...chronic_pain_yin",
        attributes: [
            { trait_type: "Benefit", value: "Pain Relief" },
            { trait_type: "Duration", value: "50 min" }
        ],
        properties: {
            category: "Wellness",
            course_type: "Yin Yoga",
            accessibility_level: "Chronic Pain Friendly",
            redeemable: true,
            instructor_certified: true,
            style: "Peaceful"
        }
    },

    // 14. Desk Detox
    {
        name: "Desk Detox Yoga: Inclusive Office",
        description: "10-minute mini sessions for people who spend long hours seated (office or wheelchair) to prevent neck and shoulder pain.",
        image: "ipfs://QmYy14...desk_detox",
        attributes: [
            { trait_type: "Duration", value: "10 min" },
            { trait_type: "Target", value: "Workers/Sedentary" }
        ],
        properties: {
            category: "Corporate",
            course_type: "Chair Yoga",
            accessibility_level: "All levels",
            redeemable: false,
            instructor_certified: true,
            style: "Minimalist"
        }
    },

    // 15. Neuro-Yoga Therapy
    {
        name: "Neuro-Yoga: Focus & Parkinson's",
        description: "Specific exercises to improve coordination and tremors, based on neuroscience studies applied to yoga.",
        image: "ipfs://QmYy15...neuro_yoga",
        attributes: [
            { trait_type: "Focus", value: "Coordination" },
            { trait_type: "Target", value: "Neuro-Disability" }
        ],
        properties: {
            category: "Medical Yoga",
            course_type: "Hatha Therapy",
            accessibility_level: "Neurological Support",
            redeemable: true,
            instructor_certified: true,
            style: "Technical"
        }
    },

    // 16. Ground Warrior
    {
        name: "Warrior of the Ground: Floor Yoga",
        description: "All the power of Warrior poses practiced exclusively on the floor. For those who cannot stand but want an intense practice.",
        image: "ipfs://QmYy16...floor_warrior",
        attributes: [
            { trait_type: "Position", value: "Floor Only" },
            { trait_type: "Focus", value: "Arms and Core Strength" }
        ],
        properties: {
            category: "Yoga",
            course_type: "Adaptive Power",
            accessibility_level: "No-Standing Required",
            redeemable: false,
            instructor_certified: true,
            style: "Modern"
        }
    },

    // 17. The Soul of Movement
    {
        name: "The Soul of Movement (YoYo Philosophy)",
        description: "Theoretical-practical masterclass on the philosophy of YoYo: why physical limits are not spiritual limits.",
        image: "ipfs://QmYy17...yoyo_philosophy",
        attributes: [
            { trait_type: "Type", value: "Theory/Practice" },
            { trait_type: "Inspiration", value: "YoYo Story" }
        ],
        properties: {
            category: "Education",
            course_type: "Raja Yoga",
            accessibility_level: "Universal Access",
            redeemable: false,
            instructor_certified: true,
            style: "Spiritual"
        }
    },

    // 18. Hip Opening
    {
        name: "Hip Opening: Freedom of the Pelvis",
        description: "Adapted sequence for opening the hips, essential for those who spend much time seated due to mobility needs.",
        image: "ipfs://QmYy18...hip_opening",
        attributes: [
            { trait_type: "Chakra", value: "Svadhisthana" },
            { trait_type: "Focus", value: "Emotional Release" }
        ],
        properties: {
            category: "Yoga",
            course_type: "Adaptive Yin",
            accessibility_level: "Seated/Floor Options",
            redeemable: false,
            instructor_certified: true,
            style: "Inclusive"
        }
    },

    // 19. Mudra & Mantra
    {
        name: "Mudra & Mantra: Yoga of the Hands",
        description: "Practice focused on hands and voice. Perfect for those with minimal or no bodily mobility.",
        image: "ipfs://QmYy19...mudra_mantra",
        attributes: [
            { trait_type: "Focus", value: "Subtle Energy" },
            { trait_type: "Type", value: "Vibrational" }
        ],
        properties: {
            category: "Spiritual",
            course_type: "Mantra Yoga",
            accessibility_level: "Universal Access",
            redeemable: false,
            instructor_certified: true,
            style: "Mystical"
        }
    },

    // 20. YoYo Consultation
    {
        name: "YoYo Consultation: Personalized Yoga",
        description: "Access to a private 1-to-1 session with a physiotherapist and a yoga teacher to map your YoYo profile.",
        image: "ipfs://QmYy20...private_session",
        attributes: [
            { trait_type: "Type", value: "Personal 1-to-1" },
            { trait_type: "Redeemable", value: "Yes" }
        ],
        properties: {
            category: "Services",
            course_type: "Consulting",
            accessibility_level: "Universal Access",
            redeemable: true,
            instructor_certified: true,
            style: "Professional"
        }
    }
];
