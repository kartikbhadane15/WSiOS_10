import SwiftUI

struct EditAddressView: View {
    @Binding var fullName: String
    @Binding var streetAddress: String
    @Binding var city: String
    @Binding var state: String
    @Binding var zipCode: String
    @Binding var country: String
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    field(label: "Full Name", text: $fullName)
                    field(label: "Street Address", text: $streetAddress)
                    field(label: "City", text: $city)
                    field(label: "State", text: $state)
                    field(label: "ZIP Code", text: $zipCode)
                    field(label: "Country", text: $country)
                }
                .padding(16)
            }
            .background(Color.white)
            .navigationTitle("Delivery Address")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                        .foregroundColor(.black)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") { dismiss() }
                        .fontWeight(.semibold)
                        .foregroundColor(.black)
                }
            }
        }
    }

    private func field(label: String, text: Binding<String>) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label)
                .font(.caption)
                .foregroundColor(.gray)
            TextField(label, text: text)
                .font(.subheadline)
                .padding(12)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color(.systemGray4), lineWidth: 1)
                )
        }
    }
}
