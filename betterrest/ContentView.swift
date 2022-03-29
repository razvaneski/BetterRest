//
//  ContentView.swift
//  betterrest
//
//  Created by Razvan Dumitriu on 29.03.2022.
//

import CoreML
import SwiftUI

struct ContentView: View {
    @State private var sleepAmount = 8.0
    @State private var wakeUp = defaultWakeTime
    @State private var coffeeAmount = 1
    
    @State private var showError = false
    
    static var defaultWakeTime: Date {
        var components = DateComponents()
        components.hour = 7
        components.minute = 0
        return Calendar.current.date(from: components) ?? Date.now
    }
    
    var body: some View {
        ZStack {
            VStack(spacing: 50) {
                NavigationView {
                    Form {
                        Section(header: Text("When would you like to wake up?")) {
                            DatePicker("Please enter a time", selection: $wakeUp, displayedComponents: .hourAndMinute)
                                .labelsHidden()
                        }
                        Section(header: Text("Desired amount of sleep")) {
                            Stepper("\(sleepAmount.formatted()) hours", value: $sleepAmount, in: 4...12, step: 0.25)
                        }
                        Section(header: Text("Daily coffee intake")) {
                            Picker("Cups of coffee", selection: $coffeeAmount) {
                                ForEach(1...20, id: \.self) { number in
                                    Text(number == 1 ? "1 cup" : "\(number) cups")
                                }
                            }
                            .pickerStyle(.wheel)
                        }
                        Section(header: Text("Recommended bed time")) {
                            Text(calculateBedtime(), style: .time)
                                .font(.largeTitle.bold())
                                .frame(maxWidth: .infinity, alignment: .center)
                                .padding()
                        }
                    }
                    .navigationTitle("BetterRest")
                    .alert("Error", isPresented: $showError) {
                        Button("OK") {}
                    } message: {
                        Text("There was an error calculating your bed time.")
                    }
                }
            }
        }
    }
    
    func calculateBedtime()-> Date {
        do {
            let config = MLModelConfiguration()
            let model = try SleepCalculator(configuration: config)
            
            let components = Calendar.current.dateComponents([.hour, .minute], from: wakeUp)
            let hour = (components.hour ?? 0) * 60 * 60
            let minute = (components.hour ?? 0) * 60
            
            let prediction = try model.prediction(wake: Double(hour + minute), estimatedSleep: sleepAmount, coffee: Double(coffeeAmount))
            
            let sleepTime = wakeUp - prediction.actualSleep
            return sleepTime
        } catch {
            showError = true
        }
        return Date.now
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
