import Cocoa
import CreateML

let data = try MLDataTable(contentsOf: URL(fileURLWithPath: "/Users/artemtkachuk/Documents/Personal/Learning/iOS/iOS 13 & Swift Bootcamp/Projects/Twitterment/ml/data/data.csv"))

let (trainingData, testingData) = data.randomSplit(by: 0.8, seed: 5)

let sentimentClassifier = try MLTextClassifier(trainingData: trainingData, textColumn: "text", labelColumn: "class")

let evaluationMetrics = sentimentClassifier.evaluation(on: testingData, textColumn: "text", labelColumn: "class")

let evaluationAccuracy = (1.0 - evaluationMetrics.classificationError) * 100
print(evaluationAccuracy)

let metadata = MLModelMetadata(author: "Artem Tkachuk", shortDescription: "A model that classifies the tweet as positive, negative, or neutral", version: "1.0")

try sentimentClassifier.write(to: URL(fileURLWithPath: "/Users/artemtkachuk/Documents/Personal/Learning/iOS/iOS 13 & Swift Bootcamp/Projects/Twitterment/TweetSentimentClassifier.mlmodel"))

//manual testing
try sentimentClassifier.prediction(from: "@Apple is a terrible company!")
try sentimentClassifier.prediction(from: "I just found the best restaurant ever, and it's @RedRobinBurgers")
try sentimentClassifier.prediction(from: "I think @Google ads are just ok.")




