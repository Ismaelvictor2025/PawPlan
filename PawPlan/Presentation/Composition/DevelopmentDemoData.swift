//
//  DevelopmentDemoData.swift
//  PawPlan
//
//  Created for PawPlan Clean Architecture.
//

import Foundation

public enum DevelopmentDemoData {
    public static func seed(container: AppDependencyContainer) {
        do {
            let existingDogs = try container.getDogsUseCase.execute()
            if !existingDogs.isEmpty { return }

            // 1. Primary Dog: Archie (Cavoodle)
            let archieId = UUID(uuidString: "A1A1A1A1-A1A1-A1A1-A1A1-A1A1A1A1A1A1")!
            let archieBirth = Calendar.current.date(byAdding: .month, value: -14, to: Date())
            let archie = Dog(
                id: archieId,
                name: "Archie",
                breed: "Cavoodle",
                birthDate: archieBirth,
                weight: 8.4,
                sex: .male,
                isDesexed: true,
                microchipNumber: "953010004928172",
                councilRegistration: "NSW-SYD-2025-0812",
                careNotes: "Friendly with other dogs. Loves fetch at Sydney Park; sensitive stomach on chicken so fed salmon kibble.",
                suburb: "Surry Hills",
                photoData: nil,
                createdAt: Date()
            )
            try container.saveDogUseCase.execute(archie)

            // 2. Second Dog: Bella (Border Collie)
            let bellaId = UUID(uuidString: "B2B2B2B2-B2B2-B2B2-B2B2-B2B2B2B2B2B2")!
            let bellaBirth = Calendar.current.date(byAdding: .year, value: -3, to: Date())
            let bella = Dog(
                id: bellaId,
                name: "Bella",
                breed: "Border Collie",
                birthDate: bellaBirth,
                weight: 18.2,
                sex: .female,
                isDesexed: true,
                microchipNumber: "953010009182746",
                councilRegistration: "NSW-WAV-2023-4910",
                careNotes: "High energy, needs mental stimulation and agility exercises. Excellent frisbee catcher.",
                suburb: "Bondi",
                photoData: nil,
                createdAt: Date().addingTimeInterval(-86400 * 30)
            )
            try container.saveDogUseCase.execute(bella)

            // 3. Archie's Care Tasks
            let calendar = Calendar.current
            let now = Date()

            let task1 = CareTask(
                id: UUID(),
                dogId: archieId,
                title: "Morning River Walk",
                category: .walk,
                recurrenceRule: .daily,
                intervalDays: 1,
                scheduledDate: calendar.date(byAdding: .minute, value: 30, to: now) ?? now,
                durationMinutes: 30,
                priority: .normal,
                notes: "Centennial Park Federation Pavilion off-leash route. Bring water bowl.",
                isCompleted: false,
                reminderEnabled: true
            )
            try container.careTaskRepository.saveTask(task1)

            let task2 = CareTask(
                id: UUID(),
                dogId: archieId,
                title: "Breakfast Salmon Kibble",
                category: .feeding,
                recurrenceRule: .daily,
                intervalDays: 1,
                scheduledDate: calendar.date(byAdding: .hour, value: 2, to: now) ?? now,
                durationMinutes: 10,
                priority: .high,
                notes: "1 cup adult salmon kibble + fresh cool water bowl.",
                isCompleted: false,
                reminderEnabled: true
            )
            try container.careTaskRepository.saveTask(task2)

            let task3 = CareTask(
                id: UUID(),
                dogId: archieId,
                title: "Flea & Tick Prevention (NexGard)",
                category: .parasitePrevention,
                recurrenceRule: .monthly,
                intervalDays: 30,
                scheduledDate: calendar.date(byAdding: .day, value: 3, to: now) ?? now,
                durationMinutes: 5,
                priority: .urgent,
                notes: "Monthly chewable tablet for Sydney paralysis tick protection.",
                isCompleted: false,
                reminderEnabled: true
            )
            try container.careTaskRepository.saveTask(task3)

            let task4 = CareTask(
                id: UUID(),
                dogId: archieId,
                title: "Evening Brush & Coat Check",
                category: .grooming,
                recurrenceRule: .daily,
                intervalDays: 1,
                scheduledDate: calendar.date(byAdding: .hour, value: 8, to: now) ?? now,
                durationMinutes: 15,
                priority: .normal,
                notes: "Slicker brush for fleece coat and daily tick palpation behind ears.",
                isCompleted: false,
                reminderEnabled: true
            )
            try container.careTaskRepository.saveTask(task4)

            // Seed recent completions for consistency score
            let yesterday = calendar.date(byAdding: .day, value: -1, to: now) ?? now
            let twoDaysAgo = calendar.date(byAdding: .day, value: -2, to: now) ?? now
            try container.careTaskRepository.recordCompletion(CareCompletion(taskId: task1.id, dogId: archieId, completedAt: yesterday, completedBy: "Owner", notes: "Great 40 min walk"))
            try container.careTaskRepository.recordCompletion(CareCompletion(taskId: task2.id, dogId: archieId, completedAt: yesterday, completedBy: "Owner", notes: "Fed on time"))
            try container.careTaskRepository.recordCompletion(CareCompletion(taskId: task1.id, dogId: archieId, completedAt: twoDaysAgo, completedBy: "Owner", notes: "Morning walk done"))

            // 4. Health Records for Archie
            let vacRecord = HealthRecord(
                id: UUID(),
                dogId: archieId,
                recordType: .vaccination,
                title: "C5 Annual Canine Booster (Parvovirus, Distemper, Hepatitis, KC)",
                recordDate: calendar.date(byAdding: .month, value: -2, to: now) ?? now,
                nextDueDate: calendar.date(byAdding: .month, value: 10, to: now),
                notes: "Administered at UVTHS Camperdown. Full health check passed with flying colours.",
                veterinarian: "Dr. Sarah Mitchell BVSc",
                batchNumber: "VAC-2025-C5-8812"
            )
            try container.healthRecordRepository.saveHealthRecord(vacRecord)

            let weightRecord = HealthRecord(
                id: UUID(),
                dogId: archieId,
                recordType: .weightLog,
                title: "Healthy Weight Check (8.4 kg)",
                recordDate: calendar.date(byAdding: .day, value: -14, to: now) ?? now,
                nextDueDate: calendar.date(byAdding: .month, value: 1, to: now),
                notes: "Body condition score: 5/9 (Ideal waist tuck and easily palpable ribs).",
                veterinarian: "UVTHS Camperdown",
                batchNumber: nil
            )
            try container.healthRecordRepository.saveHealthRecord(weightRecord)

            // 5. Vet Appointment
            let appt = VetAppointment(
                id: UUID(),
                dogId: archieId,
                clinicName: "UVTHS Camperdown Vet Hospital",
                vetName: "Dr. Sarah Mitchell",
                scheduledDate: calendar.date(byAdding: .day, value: 18, to: now) ?? now,
                reason: "Annual Dental Health Check & Heartworm ProHeart Injection",
                notes: "Mention sensitive skin around collar area.",
                contactPhone: "(02) 9351 3437",
                isCompleted: false
            )
            try container.healthRecordRepository.saveVetAppointment(appt)

            // 6. Training Progress
            let tp1 = TrainingProgress(
                id: UUID(),
                dogId: archieId,
                moduleKey: "toilet_training",
                milestoneKey: "tt_1",
                title: "Recognising Pre-Toilet Signals",
                isCompleted: true,
                completedAt: calendar.date(byAdding: .month, value: -8, to: now),
                rating: 5,
                notes: "Archie now sits near the back patio glass when he needs outside."
            )
            try container.trainingRepository.saveTrainingProgress(tp1)

            let tp2 = TrainingProgress(
                id: UUID(),
                dogId: archieId,
                moduleKey: "basic_commands",
                milestoneKey: "bc_1",
                title: "Reliable Sit & Down",
                isCompleted: true,
                completedAt: calendar.date(byAdding: .month, value: -6, to: now),
                rating: 5,
                notes: "Instant response to verbal and visual hand signal."
            )
            try container.trainingRepository.saveTrainingProgress(tp2)

            let tp3 = TrainingProgress(
                id: UUID(),
                dogId: archieId,
                moduleKey: "leash_manners",
                milestoneKey: "lm_3",
                title: "J-Shape Leash Walking",
                isCompleted: true,
                completedAt: calendar.date(byAdding: .day, value: -10, to: now),
                rating: 4,
                notes: "Practised around Surry Hills leafy backstreets. Very little pulling."
            )
            try container.trainingRepository.saveTrainingProgress(tp3)

            // 7. Expenses
            let exp1 = Expense(
                id: UUID(),
                dogId: archieId,
                category: .food,
                amount: 89.95,
                currency: "AUD",
                date: calendar.date(byAdding: .day, value: -5, to: now) ?? now,
                merchant: "PetO Alexandria",
                notes: "Black Hawk Grain-Free Salmon & Pea 7kg bag"
            )
            try container.expenseRepository.saveExpense(exp1)

            let exp2 = Expense(
                id: UUID(),
                dogId: archieId,
                category: .medication,
                amount: 64.50,
                currency: "AUD",
                date: calendar.date(byAdding: .day, value: -12, to: now) ?? now,
                merchant: "UVTHS Pharmacy",
                notes: "NexGard Spectra 3-month tick and flea chewables"
            )
            try container.expenseRepository.saveExpense(exp2)

            let exp3 = Expense(
                id: UUID(),
                dogId: archieId,
                category: .grooming,
                amount: 95.00,
                currency: "AUD",
                date: calendar.date(byAdding: .day, value: -20, to: now) ?? now,
                merchant: "Surry Hills Dog Grooming Spa",
                notes: "Full teddy-bear groom, ear clean, and paw tidy"
            )
            try container.expenseRepository.saveExpense(exp3)

            // 8. Documents
            let doc1 = DocumentRecord(
                id: UUID(),
                dogId: archieId,
                title: "C5 Vaccination Certificate 2025",
                category: .vaccinationCert,
                fileName: "archie_c5_vaccine_2025.pdf",
                fileExtension: "pdf",
                expiryDate: calendar.date(byAdding: .month, value: 10, to: now),
                createdAt: now,
                notes: "Required for Sydney dog boarding kennels and doggy daycare entry."
            )
            try container.documentRepository.saveDocument(doc1)

            let doc2 = DocumentRecord(
                id: UUID(),
                dogId: archieId,
                title: "NSW Pet Registry Certificate of Registration",
                category: .councilRegistration,
                fileName: "nsw_pet_registry_archie.pdf",
                fileExtension: "pdf",
                expiryDate: nil,
                createdAt: now,
                notes: "Official certificate issued under NSW Companion Animals Act 1998."
            )
            try container.documentRepository.saveDocument(doc2)

            // Update initial widget snapshot
            container.updateWidgetSnapshotUseCase.execute(activeDogId: archieId)
        } catch {
            print("Failed to seed demo data: \(error)")
        }
    }
}
