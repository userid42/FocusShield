import SwiftUI

struct AccountabilityStatusCard: View {
    let partner: AccountabilityPartner
    let isActive: Bool

    var body: some View {
        FocusCard {
            HStack(spacing: Spacing.md) {
                // Status indicator
                ZStack {
                    Circle()
                        .fill(isActive ? Color.success.opacity(0.1) : Color.warning.opacity(0.1))
                        .frame(width: 44, height: 44)

                    Image(systemName: isActive ? "person.fill.checkmark" : "person.fill.questionmark")
                        .font(.system(size: 18))
                        .foregroundColor(isActive ? .success : .warning)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(partner.name)
                        .font(.headlineMedium)

                    HStack(spacing: Spacing.xs) {
                        Circle()
                            .fill(isActive ? Color.success : Color.warning)
                            .frame(width: 8, height: 8)

                        Text(partner.status.rawValue)
                            .font(.labelMedium)
                            .foregroundColor(.neutral)
                    }
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.neutral)
            }
        }
    }
}

#Preview {
    VStack(spacing: Spacing.md) {
        AccountabilityStatusCard(
            partner: AccountabilityPartner(
                name: "Sarah",
                contactMethod: .email(address: "sarah@example.com"),
                status: .active
            ),
            isActive: true
        )

        AccountabilityStatusCard(
            partner: AccountabilityPartner(
                name: "John",
                contactMethod: .sms(phoneNumber: "+1234567890"),
                status: .pending
            ),
            isActive: false
        )
    }
    .padding()
    .background(Color.backgroundStart)
}
