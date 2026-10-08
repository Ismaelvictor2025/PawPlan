//
//  DocumentVaultView.swift
//  PawPlan
//
//  Created for PawPlan Document Vault.
//

import SwiftUI

public struct DocumentVaultView: View {
    @ObservedObject var container: AppDependencyContainer
    @State private var documents: [DocumentRecord] = []
    @State private var showAddDocumentSheet: Bool = false

    public init(container: AppDependencyContainer) {
        self.container = container
    }

    public var body: some View {
        ZStack {
            PawPlanTheme.background
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 20) {
                    // Security Card
                    HStack(spacing: 12) {
                        Image(systemName: "lock.shield.fill")
                            .font(.system(size: 24))
                            .foregroundColor(PawPlanTheme.electricTurquoise)

                        VStack(alignment: .leading, spacing: 2) {
                            Text("Secure Local Storage")
                                .font(.system(size: 14, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                            Text("All registration papers, certificates, and records are encrypted and kept strictly on this device.")
                                .font(.system(size: 12, weight: .medium, design: .rounded))
                                .foregroundColor(PawPlanTheme.textSecondary)
                        }
                    }
                    .padding(14)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(PawPlanTheme.cardBackgroundElevated)
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(PawPlanTheme.electricTurquoise.opacity(0.3), lineWidth: 1)
                            )
                    )
                    .padding(.horizontal, 20)
                    .padding(.top, 10)

                    // Documents List
                    VStack(spacing: 12) {
                        if documents.isEmpty {
                            Text("No documents stored yet. Tap '+' to record vaccination or council registration tags.")
                                .font(.system(size: 14, weight: .medium, design: .rounded))
                                .foregroundColor(PawPlanTheme.textSecondary)
                                .padding(.vertical, 20)
                        } else {
                            ForEach(documents) { doc in
                                DocumentRowCard(doc: doc)
                            }
                        }
                    }
                    .padding(.horizontal, 20)

                    Spacer(minLength: 40)
                }
                .padding(.bottom, 20)
            }
        }
        .navigationTitle("Document Vault")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    showAddDocumentSheet = true
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(PawPlanTheme.electricTurquoise)
                }
            }
        }
        .sheet(isPresented: $showAddDocumentSheet) {
            AddDocumentModal(container: container, isPresented: $showAddDocumentSheet)
                .onDisappear { loadDocuments() }
        }
        .onAppear { loadDocuments() }
        .onChange(of: container.activeDog) { _ in loadDocuments() }
    }

    private func loadDocuments() {
        guard let dog = container.activeDog else { return }
        do {
            documents = try container.documentRepository.fetchDocuments(for: dog.id)
        } catch {
            print("Failed to load documents: \(error)")
        }
    }
}

private struct DocumentRowCard: View {
    let doc: DocumentRecord

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(PawPlanTheme.lightCyan.opacity(0.15))
                    .frame(width: 44, height: 44)
                Image(systemName: doc.category.iconName)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(PawPlanTheme.lightCyan)
            }

            VStack(alignment: .leading, spacing: 3) {
                Text(doc.title)
                    .font(.system(size: 15, weight: .bold, design: .rounded))
                    .foregroundColor(.white)

                Text(doc.category.rawValue)
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                    .foregroundColor(PawPlanTheme.electricTurquoise)

                if let notes = doc.notes, !notes.isEmpty {
                    Text(notes)
                        .font(.system(size: 11, weight: .medium, design: .rounded))
                        .foregroundColor(PawPlanTheme.textSecondary)
                        .lineLimit(1)
                }
            }

            Spacer()

            Image(systemName: "doc.text.magnifyingglass")
                .foregroundColor(PawPlanTheme.textSecondary)
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(PawPlanTheme.cardGradient)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(PawPlanTheme.cardBorder, lineWidth: 1)
                )
        )
    }
}

public struct AddDocumentModal: View {
    @ObservedObject var container: AppDependencyContainer
    @Binding var isPresented: Bool

    @State private var title: String = ""
    @State private var category: DocumentCategory = .vaccinationCert
    @State private var fileName: String = "certificate.pdf"
    @State private var notes: String = ""

    public var body: some View {
        NavigationView {
            ZStack {
                PawPlanTheme.background
                    .ignoresSafeArea()

                Form {
                    Section(header: Text("Document Information").foregroundColor(PawPlanTheme.textSecondary)) {
                        TextField("Document Title (e.g. C5 Certificate)", text: $title)
                        Picker("Category", selection: $category) {
                            ForEach(DocumentCategory.allCases, id: \.self) { c in
                                Text(c.rawValue).tag(c)
                            }
                        }
                        TextField("File Reference Name", text: $fileName)
                        TextField("Notes / Policy Number", text: $notes)
                    }
                    .listRowBackground(PawPlanTheme.cardBackgroundElevated)
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Add Document")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { isPresented = false }
                        .foregroundColor(PawPlanTheme.textSecondary)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        guard let dog = container.activeDog else { return }
                        let doc = DocumentRecord(
                            dogId: dog.id,
                            title: title.isEmpty ? category.rawValue : title,
                            category: category,
                            fileName: fileName,
                            notes: notes.isEmpty ? nil : notes
                        )
                        try? container.documentRepository.saveDocument(doc)
                        isPresented = false
                    }
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundColor(PawPlanTheme.electricTurquoise)
                }
            }
        }
    }
}
