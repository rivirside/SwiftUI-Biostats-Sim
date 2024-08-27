import SwiftUI
import Charts


@main
struct MyApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

struct ContentView: View {
    var body: some View {
        DiagnosticSimulationView()
    }
}


struct DiagnosticSimulationView: View {
    @State private var sensitivity: Double = 0.9
    @State private var specificity: Double = 0.9
    @State private var prevalence: Double = 0.1
    @State private var populationSize: Int = 1000
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                HStack {
                    Spacer()
                    Text("Testing Simulation").font(.headline)
                    Spacer()
                }
                Divider()
                Text("Sensitivity: \(sensitivity, specifier: "%.2f")")
                Slider(value: $sensitivity, in: 0...1, step: 0.01)
                
                Text("Specificity: \(specificity, specifier: "%.2f")")
                Slider(value: $specificity, in: 0...1, step: 0.01)
                
                Text("Prevalence: \(prevalence, specifier: "%.2f")")
                Slider(value: $prevalence, in: 0...1, step: 0.01)
                
                HStack {
                    Spacer()
                    Text("Population Size: \(populationSize)")
                    Spacer()
                    // Display composite accuracy
                    Text("Accuracy: \(calculateAccuracy(), specifier: "%.2f")")
                    Spacer()
                }
                
            }
            .padding()
            
            // Displaying the simulation results using a Chart
            ChartView(sensitivity: sensitivity, specificity: specificity, prevalence: prevalence, populationSize: populationSize)
                .frame(height: 300)
            
            // Additional summary statistics with explanations
            VStack(alignment: .leading) {
                DetailView(
                    title: "NPV (Negative Predictive Value)",
                    value: String(format: "%.2f", calculateNPV()),
                    explanation: """
        NPV is the probability that a subject who tests negative actually does not have the disease. 
        It is calculated as:
        NPV = (True Negatives) / (True Negatives + False Negatives)
        A high NPV indicates that a negative result from the test is a good indication that the person is disease-free.
        """
                )
                
                DetailView(
                    title: "PPV (Positive Predictive Value)",
                    value: String(format: "%.2f", calculatePPV()),
                    explanation: """
        PPV is the probability that a subject who tests positive actually has the disease.
        It is calculated as:
        PPV = (True Positives) / (True Positives + False Positives)
        A high PPV means that a positive result from the test is a reliable indicator of disease presence.
        """
                )
                
                DetailView(
                    title: "True Positive Rate (Sensitivity)",
                    value: String(format: "%.2f", sensitivity),
                    explanation: """
        Sensitivity, or True Positive Rate, measures the test's ability to correctly identify those with the disease.
        It is calculated as:
        Sensitivity = (True Positives) / (True Positives + False Negatives)
        A high sensitivity means the test is good at detecting the disease in those who have it.
        """
                )
                
                DetailView(
                    title: "True Negative Rate (Specificity)",
                    value: String(format: "%.2f", specificity),
                    explanation: """
        Specificity, or True Negative Rate, measures the test's ability to correctly identify those without the disease.
        It is calculated as:
        Specificity = (True Negatives) / (True Negatives + False Positives)
        A high specificity indicates that the test effectively identifies individuals who do not have the disease.
        """
                )
                
                DetailView(
                    title: "False Positive Rate",
                    value: String(format: "%.2f", (1 - specificity)),
                    explanation: """
        False Positive Rate is the proportion of subjects without the disease who incorrectly test positive.
        It is calculated as:
        False Positive Rate = 1 - Specificity
        A lower false positive rate means fewer healthy individuals are mistakenly identified as having the disease.
        """
                )
                
                DetailView(
                    title: "False Negative Rate",
                    value: String(format: "%.2f", (1 - sensitivity)),
                    explanation: """
        False Negative Rate is the proportion of subjects with the disease who incorrectly test negative.
        It is calculated as:
        False Negative Rate = 1 - Sensitivity
        A lower false negative rate indicates fewer individuals with the disease are missed by the test.
        """
                )
                
                DetailView(
                    title: "F1 Score",
                    value: String(format: "%.2f", calculateF1Score()),
                    explanation: """
        The F1 Score is the harmonic mean of Precision (PPV) and Recall (Sensitivity). 
        It balances the trade-off between Precision and Recall.
        It is calculated as:
        F1 Score = 2 * (Precision * Recall) / (Precision + Recall)
        A higher F1 Score indicates a better balance between Precision and Recall.
        """
                )
                
                DetailView(
                    title: "Matthews Correlation Coefficient (MCC)",
                    value: String(format: "%.2f", calculateMCC()),
                    explanation: """
        The MCC is a measure of the quality of binary classifications. It considers all four confusion matrix categories (TP, FP, TN, FN).
        It is calculated as:
        MCC = (TP * TN - FP * FN) / sqrt((TP + FP) * (TP + FN) * (TN + FP) * (TN + FN))
        MCC ranges from -1 (total disagreement) to 1 (perfect prediction), with 0 indicating no better than random prediction.
        """
                )
                
                DetailView(
                    title: "Balanced Accuracy",
                    value: String(format: "%.2f", calculateBalancedAccuracy()),
                    explanation: """
        Balanced Accuracy is the average of Sensitivity and Specificity.
        It is calculated as:
        Balanced Accuracy = (Sensitivity + Specificity) / 2
        This metric provides a balanced view of performance, especially in imbalanced datasets.
        """
                )
                
                DetailView(
                    title: "False Discovery Rate (FDR)",
                    value: String(format: "%.2f", calculateFDR()),
                    explanation: """
        FDR is the proportion of false positives among the positive test results.
        It is calculated as:
        FDR = (False Positives) / (True Positives + False Positives)
        A lower FDR indicates fewer false positives among the declared positives.
        """
                )
                
                DetailView(
                    title: "AUC (Approximation)",
                    value: String(format: "%.2f", calculateAUC()),
                    explanation: """
        AUC represents the area under the ROC curve, approximating the test's performance across different thresholds.
        It is a measure of the test's ability to discriminate between positive and negative cases.
        While this implementation is a simplified approximation, a higher AUC indicates better overall test performance.
        """
                )
            }
            .padding()
            
            Spacer()
        }
        .padding()
    }
    
    // True Positives
    func truePositives() -> Double {
        return prevalence * sensitivity * Double(populationSize)
    }
    
    // False Positives
    func falsePositives() -> Double {
        return (1 - prevalence) * (1 - specificity) * Double(populationSize)
    }
    
    // True Negatives
    func trueNegatives() -> Double {
        return (1 - prevalence) * specificity * Double(populationSize)
    }
    
    // False Negatives
    func falseNegatives() -> Double {
        return prevalence * (1 - sensitivity) * Double(populationSize)
    }
    
    // Positive Predictive Value (PPV)
    func calculatePPV() -> Double {
        let tp = truePositives()
        let fp = falsePositives()
        return tp / (tp + fp)
    }
    
    // Negative Predictive Value (NPV)
    func calculateNPV() -> Double {
        let tn = trueNegatives()
        let fn = falseNegatives()
        return tn / (tn + fn)
    }
    
    // Composite Accuracy
    func calculateAccuracy() -> Double {
        let tp = truePositives()
        let tn = trueNegatives()
        return (tp + tn) / Double(populationSize)
    }
    
    // F1 Score
    func calculateF1Score() -> Double {
        let precision = calculatePPV()
        let recall = sensitivity
        guard (precision + recall) > 0 else { return 0 }
        return 2 * (precision * recall) / (precision + recall)
    }
    
    // Matthews Correlation Coefficient (MCC)
    func calculateMCC() -> Double {
        let tp = truePositives()
        let fp = falsePositives()
        let tn = trueNegatives()
        let fn = falseNegatives()
        let numerator = (tp * tn) - (fp * fn)
        let denominator = sqrt((tp + fp) * (tp + fn) * (tn + fp) * (tn + fn))
        return denominator == 0 ? 0 : numerator / denominator
    }
    
    // Balanced Accuracy
    func calculateBalancedAccuracy() -> Double {
        return (sensitivity + specificity) / 2
    }
    
    // False Discovery Rate (FDR)
    func calculateFDR() -> Double {
        let tp = truePositives()
        let fp = falsePositives()
        return (tp + fp) == 0 ? 0 : fp / (tp + fp)
    }
    
    // AUC (Approximation using Sensitivity and Specificity)
    func calculateAUC() -> Double {
        // Will return to adjust this after, for now balanced accuracy
        return (sensitivity + specificity) / 2
    }
}

struct ChartView: View {
    var sensitivity: Double
    var specificity: Double
    var prevalence: Double
    var populationSize: Int
    
    var body: some View {
        let tp = truePositives()
        let fp = falsePositives()
        let tn = trueNegatives()
        let fn = falseNegatives()
        
        let data = [
            ("True Positives", tp),
            ("False Positives", fp),
            ("True Negatives", tn),
            ("False Negatives", fn)
        ]
        
        Chart {
            ForEach(data, id: \.0) { category, value in
                BarMark(
                    x: .value("Category", category),
                    y: .value("Count", value)
                )
                .foregroundStyle(by: .value("Category", category))
            }
        }
    }
    
    // Reusing the functions from the main view
    func truePositives() -> Double {
        return prevalence * sensitivity * Double(populationSize)
    }
    
    func falsePositives() -> Double {
        return (1 - prevalence) * (1 - specificity) * Double(populationSize)
    }
    
    func trueNegatives() -> Double {
        return (1 - prevalence) * specificity * Double(populationSize)
    }
    
    func falseNegatives() -> Double {
        return prevalence * (1 - sensitivity) * Double(populationSize)
    }
}


struct DetailView: View {
    let title: String
    let value: String
    let explanation: String
    
    @State private var isExpanded = false
    
    var body: some View {
        VStack(alignment: .leading) {
            Button(action: {
                withAnimation {
                    isExpanded.toggle()
                }
            }) {
                HStack {
                    Text("\(title): \(value)")
                        .font(.headline)
                        .foregroundColor(.blue)
                    Spacer()
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .foregroundColor(.blue)
                }
            }
            
            if isExpanded {
                Text(explanation)
                    .padding(.top, 5)
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
        }
        .padding(.bottom, 10)
    }
}
