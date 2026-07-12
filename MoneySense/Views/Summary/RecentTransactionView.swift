import SwiftUI
import Shimmer

struct RecentTransactionView: View {
    var viewModel: RecentTransactionViewModel
    let currencyCode: String
    var isSeeAllDisabled: Bool = false
    
    private var displayTransactions: [Transaction] {
        viewModel.isLoading ? (0..<5).map { _ in .placeholder } : viewModel.transactions
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Recent Transactions")
                    .font(.headline)
                
                Spacer()
                
                NavigationLink(value: SummaryRoute.allTransactions) {
                    HStack(spacing: 4) {
                        Text("See All")
                        Image(systemName: "chevron.right")
                    }
                    .font(.subheadline)
                }
                .disabled(isSeeAllDisabled)
                .opacity(isSeeAllDisabled ? 0.4 : 1)
            }
            .padding(.horizontal, 12)
            
            Card(spacing: 0, padding: 0) {
                ForEach(displayTransactions.indices, id: \.self) { index in
                    TransactionRowView(transaction: displayTransactions[index], currencyCode: currencyCode)
                        .redacted(reason: viewModel.isLoading ? .placeholder : [])
        
                    if index != displayTransactions.count - 1 {
                        Divider().padding(.leading, 60)
                    }
                }
            }
            .shimmering(active: viewModel.isLoading)
        }
        .task {
            guard viewModel.transactions.isEmpty else { return }
            await viewModel.load()
        }
    }
}
